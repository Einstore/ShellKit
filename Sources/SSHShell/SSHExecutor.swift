import ExecutorKit
import Shout
import NIO


/// SSH executor
public class SSHExecutor: Executor {
    
    public var output: ((String) -> ())?
    
    public let eventLoop: EventLoop
    let ssh: SSH
    var sftp: SFTP?
    
    let workDir: String
    
    /// Initializer
    /// - Parameter dir: Current working directory, defaults to `~/`
    /// - Parameter host: SSH host
    /// - Parameter port: SSH port
    /// - Parameter username: Login username
    /// - Parameter auth: Authentication
    /// - Parameter loop: Event loop
    public init(workDir dir: String = "~/", host: String, port: Int = 22, username: String, auth: SSHAuthMethod, on loop: EventLoop) throws {
        workDir = dir
        eventLoop = loop
        ssh = try SSH(host: host, port: Int32(port))
        try ssh.authenticate(username: username, authMethod: auth)
    }
    
    /// Run bash command
    /// - Parameter bash: bash command
    /// - Parameter output: Future containing an exit code
    public func run(bash: String, output: ((String) -> ())? = nil) -> ProcessFuture<String> {
        let promise = eventLoop.makePromise(of: String.self)
        DispatchQueue.global(qos: .background).async {
            do {
                var outputText = ""
                let res = try self.ssh.execute("cd \(self.workDir) ; \(bash)") { text in
                    outputText += text
                    self.eventLoop.execute {
                        output?(text)
                        self.output?(text)
                    }
                }
                if res == 0 {
                    self.eventLoop.execute {
                        promise.succeed(outputText)
                    }
                } else {
                    self.eventLoop.execute {
                        #warning("Replace `.exit` with a real termination reason!!!")
                        promise.fail(
                            ShellError.badExitCode(
                                command: bash,
                                exit: Exit(
                                    terminationStatus: res,
                                    terminationReason: .exit
                                ),
                                output: outputText
                            )
                        )
                    }
                }
            } catch {
                self.eventLoop.execute {
                    promise.fail(error)
                }
            }
        }
        return ProcessFuture(future: promise.futureResult) {
            #warning("Terminate process!!!!!")
        }
    }
    
    /// Run command
    /// - Parameter command: Command
    /// - Parameter args: Arguments
    /// - Parameter output: Closure to output console text
    public func run(command: String, args: [String], output: ((String) -> ())? = nil) -> ProcessFuture<String> {
        let cmd = command + ((args.count > 0) ? (" " + args.joined(separator: " ")) : "")
        return run(bash: cmd, output: output)
    }
    
    /// Check if file exists
    /// - Parameter path: Path to the file
    public func file(exists path: String) -> EventLoopFuture<Bool> {
        let command = """
        FILE=\(path)
        if [ -f "$FILE" ]; then
            echo "exists"
        else
            echo "does not exist"
        fi
        """
        return run(bash: command).future.map { result in
            return result.trimmingCharacters(in: .whitespacesAndNewlines) == "exists"
        }
    }
    
    /// Check if folder exists
    /// - Parameter path: Path to the file
    public func folder(exists path: String) -> EventLoopFuture<Bool> {
        let command = """
        DIR=\(path)
        if [ -d "$DIR" ]; then
            echo "exists"
        else
            echo "does not exist"
        fi
        """
        return run(bash: command).future.map { result in
            return result.trimmingCharacters(in: .whitespacesAndNewlines) == "exists"
        }
    }
    
    /// Set current working directory
    /// - Parameter path: Path
    public func cd(path: String) -> EventLoopFuture<Void> {
        return run(bash: "cd \(path.quoteEscape)").future.map { _ in Void() }
    }
    
    /// Upload string as a file
    /// - Parameter string: Path to a local file
    /// - Parameter to: Destination path (including filename)
    public func upload(string: String, to path: String) -> EventLoopFuture<Void> {
        guard let data = string.data(using: .utf8) else {
            return eventLoop.makeFailedFuture(ShellError.unableToConvertStringToData)
        }
        return upload(data: data, to: path)
    }
    
    /// Upload data as a file
    /// - Parameter data: Path to a local file
    /// - Parameter to: Destination path (including filename)
    public func upload(data: Data, to path: String) -> EventLoopFuture<Void> {
        let promise = eventLoop.makePromise(of: Void.self)
        DispatchQueue.global(qos: .background).async {
            do {
                if self.sftp == nil {
                    self.sftp = try self.ssh.openSftp()
                }
                try self.sftp?.upload(data: data, remotePath: path)
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
    public func upload(file: String, to path: String) -> EventLoopFuture<Void> {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return upload(data: data, to: path)
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
    
}
