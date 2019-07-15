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
    var context: CustomContext
    
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
        self.context = CustomContext(main)
        context.currentdirectory = dir
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
                let stdout = cmd.stdout.read()
                let ret: String
                if let outputText = outputText {
                    ret = outputText + stdout
                } else {
                    ret = stdout
                }
                if exit == 0 {
                    promise.succeed(ret)
                } else {
                    promise.fail(Shell.Error.badExitCode(command: command, exit: exit, output: ret))
                }
            }
        }
        return promise.futureResult
    }
    
    /// Run command
    /// - Parameter command: Command
    /// - Parameter args: Arguments
    /// - Parameter output: Closure to output console text
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
                    self.eventLoop.execute {
                        output(text)
                    }
                }
            }
            out.onCompletion { cmd in
                let exit = Int32(cmd.exitcode())
                let stdout = cmd.stdout.read()
                if outputText == nil && !stdout.isEmpty {
                    self.eventLoop.execute {
                        output?(stdout)
                    }
                }
                if exit == 0 {
                    self.eventLoop.execute {
                        promise.succeed(outputText ?? stdout)
                    }
                } else {
                    self.eventLoop.execute {
                        promise.fail(Shell.Error.badExitCode(command: command, exit: exit, output: outputText ?? ""))
                    }
                }
            }
        }
        return promise.futureResult
    }
    
    /// Check if file exists
    /// - Parameter path: Path to the file
    public func exists(path: String) -> EventLoopFuture<Bool> {
        let exists = FileManager.default.fileExists(atPath: path)
        return eventLoop.makeSucceededFuture(exists)
    }
    
    /// Set current working directory
    /// - Parameter path: Path
    public func cd(path dir: String) -> EventLoopFuture<Void> {
        if let first = dir.first, first == "~" {
            return eventLoop.makeFailedFuture(Error.useAbsolutePath(dir))
        }
        if !FileManager.default.fileExists(atPath: dir) {
            return eventLoop.makeFailedFuture(Error.pathDoesNotExist(dir))
        }
        
        context.currentdirectory = dir
        
        return eventLoop.makeSucceededFuture(Void())
    }
    
    /// Upload string as a file
    /// - Parameter string: Path to a local file
    /// - Parameter to: Destination path (including filename)
    public func upload(string: String, to path: String) -> EventLoopFuture<Void> {
        guard let data = string.data(using: .utf8) else {
            return eventLoop.makeFailedFuture(Shell.Error.unableToConvertStringToData)
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
                try data.write(to: URL(fileURLWithPath: path))
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
