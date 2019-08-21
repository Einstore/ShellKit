import Foundation
import ExecutorKit
import NIO


public class LocalExecutor: Executor {
    
    public var output: ((String) -> ())? = nil
    
    public enum LocalExecutorError: SerializableWebError {
        
        case processFailed(exit: Int32)
        
        public var serializedCode: String {
            return "process_failed"
        }
        
        public var reason: String? {
            switch self {
            case .processFailed(exit: let exit):
                return "Process failed with exit code \(exit)"
            }
        }
        
    }
    
    public let eventLoop: EventLoop
    public private(set) var currentDirectoryPath: String
    let identifier: String = UUID().uuidString
    
    /// Initializer
    /// - Parameter currentDirectoryPath: Current working directory, defaults to `~/`
    /// - Parameter eventLoop: EventLoop
    public init(currentDirectoryPath dir: String, on e: EventLoop) {
        currentDirectoryPath = dir
        eventLoop = e
    }
    
    /// Run bash command
    /// - Parameter bash: bash command
    /// - Parameter output: Future containing an exit code
    public func run(bash: String, output: ((String) -> ())? = nil) -> ProcessFuture<String> {
        return run(command: "-c", args: [bash], output: output)
    }
    
    /// Run command
    /// - Parameter command: Command
    /// - Parameter args: Arguments
    /// - Parameter output: Closure to output console text
    public func run(command: String, args: [String], output: ((String) -> ())? = nil) -> ProcessFuture<String> {
        let promise = eventLoop.makePromise(of: String.self)
        let pipe = Pipe()
        
        let p = Process()
        p.currentDirectoryPath = self.currentDirectoryPath
        p.launchPath = "/bin/bash"
        var arguments = [command]
        arguments.append(contentsOf: args)
        p.arguments = arguments
        
        var environment =  ProcessInfo.processInfo.environment
        if var path = environment["PATH"] {
            if !path.contains("/usr/local/bin") {
                path.append(":/usr/local/bin")
                environment["PATH"] = path
            }
        } else {
            environment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        }
        p.environment = environment
        
        p.standardOutput = pipe.fileHandleForWriting
        
        let queue = DispatchQueue(label: self.identifier)
        let channel = DispatchIO(
            type: .stream,
            fileDescriptor: pipe.fileHandleForReading.fileDescriptor,
            queue: queue,
            cleanupHandler: { err in
                if err != 0 {
                    print("Error: \(err)")
                }
                promise.fail(ShellError.processTerminated)
                close(pipe.fileHandleForReading.fileDescriptor)
            }
        )
        channel.setLimit(lowWater: 1)
        var outputText = ""
        channel.read(offset: 0, length: .max, queue: queue) { done, data, err in
            guard err == 0 else {
                print("Read error: \(err)")
                return
            }
            if let text = data.map({ String(decoding: $0, as: Unicode.UTF8.self) }), !text.isEmpty {
                outputText.append(text)
                output?(text)
                self.output?(text)
                print(text, terminator: "")
            }
        }
        p.terminationHandler = { p in
            if p.terminationStatus == 0 {
                print("I am here!!!!")
                
                promise.succeed(outputText)
            } else {
                let cmd = arguments.joined(separator: " ")
                promise.fail(
                    ShellError.badExitCode(
                        command: cmd,
                        exit: Exit(
                            terminationStatus: p.terminationStatus,
                            terminationReason: p.terminationReason
                        ),
                        output: outputText
                    )
                )
            }
        }
        
        p.launch()
        
        return ProcessFuture(future: promise.futureResult) {
            p.terminate()
        }
    }
    
    /// Check if file exists
    /// - Parameter path: Path to the file
    public func file(exists path: String) -> EventLoopFuture<Bool> {
        var dir: ObjCBool = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &dir)
        return eventLoop.makeSucceededFuture(exists && !dir.boolValue)
    }
    
    /// Check if folder exists
    /// - Parameter path: Path to the file
    public func folder(exists path: String) -> EventLoopFuture<Bool> {
        var dir: ObjCBool = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &dir)
        return eventLoop.makeSucceededFuture(exists && dir.boolValue)
    }
    
    /// Set current working directory
    /// - Parameter path: Path
    public func cd(path: String) -> EventLoopFuture<Void> {
        currentDirectoryPath = path
        return eventLoop.makeSucceededFuture(Void())
    }
    
    /// Upload string as a file
    /// - Parameter string: Path to a local file
    /// - Parameter to: Destination path (including filename)
    public func upload(file path: String, to destination: String) -> EventLoopFuture<Void> {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return upload(data: data, to: destination)
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
    
    /// Upload data as a file
    /// - Parameter data: Path to a local file
    /// - Parameter to: Destination path (including filename)
    public func upload(data: Data, to destination: String) -> EventLoopFuture<Void> {
        let promise = eventLoop.makePromise(of: Void.self)
        DispatchQueue.global(qos: .background).async {
            do {
                try data.write(to: URL(fileURLWithPath: destination))
                self.eventLoop.execute {
                    promise.succeed(Void())
                }
            } catch {
                self.eventLoop.execute {
                    promise.fail(error)
                }
            }
        }
        return promise.futureResult
    }
    
    /// Upload a file
    /// - Parameter file: Path to a local file
    /// - Parameter to: Destination path (including filename)
    public func upload(string: String, to destination: String) -> EventLoopFuture<Void> {
        guard let data = string.data(using: .utf8) else {
            return eventLoop.makeFailedFuture(ShellError.unableToConvertStringToData)
        }
        return upload(data: data, to: destination)
    }
    
}
