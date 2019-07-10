//
//  LocalExecutor.swift
//  
//
//  Created by Ondrej Rafaj on 04/07/2019.
//

import Foundation
import SwiftShell
import NIO


/// Local filesystem executor
public class LocalExecutor: Executor {
    
    public enum Error: Swift.Error {
        case useAbsolutePath(String)
        case pathDoesNotExist(String)
    }
    
    let eventLoop: EventLoop
    let context: CustomContext
    
    
    /// Initializer
    /// - Parameter dir: Current working directory, defaults to `~/`
    /// - Parameter eventLoop: Event loop
    public init(workDir dir: String = "/tmp", on eventLoop: EventLoop) throws {
        if let first = dir.first, first == "~" {
            throw Error.useAbsolutePath(dir)
        }
        if !FileManager.default.fileExists(atPath: dir) {
            throw Error.pathDoesNotExist(dir)
        }
        self.eventLoop = eventLoop
        var context = CustomContext(main)
        context.currentdirectory = dir
        self.context = context
    }
    
    /// Run bash command
    /// - Parameter bash: bash command
    /// - Parameter output: Future containing an exit code
    public func run(bash command: String, output: ((String) -> ())? = nil) -> EventLoopFuture<String> {
        let promise = eventLoop.makePromise(of: Output.self)
        DispatchQueue.global(qos: .background).async {
            var outputText: String?
            let out = self.context.runAsync(bash: command)
            if let output = output {
                out.stdout.onStringOutput { text in
                    if let ot = outputText {
                        outputText = ot + text
                    } else {
                        outputText = text
                    }
                    output(text)
                }
            }
            out.onCompletion { cmd in
                let exit = Int32(cmd.exitcode())
                #warning("Append stdout to already outputed text in outputText to get the whole message!")
                let stdout = cmd.stdout.read()
                if outputText == nil && !stdout.isEmpty {
                    output?(stdout)
                }
                if exit == 0 {
                    promise.succeed(outputText ?? stdout)
                } else {
                    promise.fail(Shell.Error.badExitCode(command: command, exit: exit, output: outputText ?? ""))
                }
            }
        }
        return promise.futureResult
    }
    
    public func run(command: String, args: [String], output: ((String) -> ())? = nil) -> EventLoopFuture<String> {
        let promise = eventLoop.makePromise(of: Output.self)
        DispatchQueue.global(qos: .background).async {
            var outputText: String?
            let out = self.context.runAsync(command, args)
            if let output = output {
                out.stdout.onStringOutput { text in
                    if let ot = outputText {
                        outputText = ot + text
                    } else {
                        outputText = text
                    }
                    output(text)
                }
            }
            out.onCompletion { cmd in
                let exit = Int32(cmd.exitcode())
                let stdout = cmd.stdout.read()
                if outputText == nil && !stdout.isEmpty {
                    output?(stdout)
                }
                if exit == 0 {
                    promise.succeed(outputText ?? stdout)
                } else {
                    promise.fail(Shell.Error.badExitCode(command: command, exit: exit, output: outputText ?? ""))
                }
            }
        }
        return promise.futureResult
    }
    
    public func exists(path: String) -> EventLoopFuture<Bool> {
        let exists = FileManager.default.fileExists(atPath: path)
        return eventLoop.makeSucceededFuture(exists)
    }
    
}
