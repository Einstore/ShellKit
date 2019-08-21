import Foundation
import ExecutorKit
import ShellKit


public class ExecutorMock: MasterExecutor {
    
    public var executor: Executor {
        return self
    }
    
    public var output: ((String) -> ())? = nil
    
    /// Event loop on which all commands execute
    public var eventLoop: EventLoop = EmbeddedEventLoop()
    
    /// Commads registered for commands
    ///     - Note: Format is [Command: [Output piece]]
    public var mockResults: [String: [String]] = [:]
    
    /// Errors for results that are supposed to fail
    public var failingMockResults: [String: Error] = [:]
    
    public func run(bash: String, output: ((String) -> ())?) -> ProcessFuture<String> {
        guard let response = mockResults[bash] else {
            guard let error = failingMockResults[bash] else {
                fatalError("[ShellKit] Missing mock response for:\n\(bash)\n\n")
            }
            let f: EventLoopFuture<String> = eventLoop.makeFailedFuture(error)
            return ProcessFuture<String>(future: f, cancel: {  })
        }
        log(cmd: bash)
        var out = ""
        for step in response {
            output?(step)
            out.append(step)
        }
        let f = eventLoop.makeSucceededFuture(out)
        return ProcessFuture<String>(future: f, cancel: {  })
    }
    
    public func run(command: String, args: [String], output: ((String) -> ())?) -> ProcessFuture<String> {
        var cmd = command
        for arg in args {
            cmd.append(" ")
            cmd.append(arg)
        }
        return run(bash: cmd, output: output)
    }
    
    /// Existing paths
    public var existingPaths: [String] = []
    
    public func file(exists path: String) -> EventLoopFuture<Bool> {
        guard let _ = existingPaths.lastIndex(of: path) else {
            return eventLoop.makeSucceededFuture(false)
        }
        return eventLoop.makeSucceededFuture(true)
    }
    
    public func folder(exists path: String) -> EventLoopFuture<Bool> {
        return file(exists: path)
    }
    
    /// Current path
    public var currentPath = ""
    
    public func cd(path: String) -> EventLoopFuture<Void> {
        currentPath = path
        return eventLoop.makeSucceededFuture(Void())
    }
    
    public func upload(file: String, to path: String) -> EventLoopFuture<Void> {
        return upload(data: file.data(using: .utf8)!, to: path)
    }
    
    public func upload(data: Data, to path: String) -> EventLoopFuture<Void> {
        log(cmd: "Upload \(data.count) bytes to \(path)")
        uploaded[path] = data
        return eventLoop.makeSucceededFuture(Void())
    }
    
    /// Uploaded files and data
    public var uploaded: [String: Data] = [:]
    
    public func upload(string: String, to path: String) -> EventLoopFuture<Void> {
        return upload(data: string.data(using: .utf8)!, to: path)
    }
    
    public init() { }
    
}


extension ExecutorMock {
    
    fileprivate func log(cmd: String) {
        print("[ShellKit] CMD: \(cmd)")
    }
    
}
