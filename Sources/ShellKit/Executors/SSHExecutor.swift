//
//  SSHExecutor.swift
//  
//
//  Created by Ondrej Rafaj on 04/07/2019.
//

import Foundation
import Shout
import NIO


/// SSH executor
public class SSHExecutor: Executor {
    
    let eventLoop: EventLoop
    let ssh: SSH
    
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
    public func run(bash: String, output: ((String) -> ())? = nil) -> EventLoopFuture<Output> {
        let promise = eventLoop.makePromise(of: Output.self)
        DispatchQueue.global(qos: .background).async {
            do {
                var outputText = ""
                let res = try self.ssh.execute("cd \(self.workDir) ; \(bash)") { text in
                    outputText += text
                    output?(text)
                }
                if res == 0 {
                    promise.succeed(outputText)
                } else {
                    promise.fail(Shell.Error.badExitCode(command: bash, exit: res, output: outputText))
                }
            } catch {
                promise.fail(error)
            }
        }
        return promise.futureResult
    }
    
    /// Run command
    /// - Parameter command: Command
    /// - Parameter args: Arguments
    /// - Parameter output: Closure to output console text
    public func run(command: String, args: [String], output: ((String) -> ())? = nil) -> EventLoopFuture<String> {
        let cmd = command + ((args.count > 0) ? (" " + args.joined(separator: " ")) : "")
        return run(bash: cmd, output: output)
    }
    
    /// Check if file exists
    /// - Parameter path: Path to the file
    public func exists(path: String) -> EventLoopFuture<Bool> {
        let command = """
        FILE=\(path)
        if [ -f "$FILE" ]; then
            echo "$FILE exists"
        else
            echo "$FILE does not exist"
        fi
        """
        return run(bash: command).map { result in
            return result.contains("\(path) exists")
        }
    }
    
    /// Set current working directory
    /// - Parameter path: Path
    public func cd(path: String) -> EventLoopFuture<Void> {
        return run(bash: "cd \(path.quoteEscape)").void()
    }
    
}
