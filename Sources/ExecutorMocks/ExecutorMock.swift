import Foundation
import ExecutorKit


public class ExecutorMock: Executor {
    
    public let eventLoop = EmbeddedEventLoop()
    
    public var responses: [String: [String]] = [:]
    
    public var failingResponses: [String: Error] = [:]
    
    public func run(bash: String, output: ((String) -> ())?) -> ProcessFuture<String> {
        guard let response = responses[bash] else {
            guard let error = failingResponses[bash] else {
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
    
    public var uploaded: [String: Data] = [:]
    
    public func upload(string: String, to path: String) -> EventLoopFuture<Void> {
        return upload(data: string.data(using: .utf8)!, to: path)
    }
    
}


extension ExecutorMock {
    
    fileprivate func log(cmd: String) {
        print("[ShellKit] CMD: \(cmd)")
    }
    
}
