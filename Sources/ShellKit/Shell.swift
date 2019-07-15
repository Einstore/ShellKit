//
//  Shell.swift
//  
//
//  Created by Ondrej Rafaj on 04/07/2019.
//

import Foundation
import NIO


/// Main executor
public class Shell: Executor {
    
    /// Basic error
    public enum Error: Swift.Error {
        
        /// Bad exit code error
        case badExitCode(command: String, exit: Int32, output: String)
        
        /// Umable to convert string to `.utf8` data
        case unableToConvertStringToData
        
    }
    
    /// Connection type
    public struct Connection {
        
        enum Storage {
            case local(dir: String)
            case ssh(host: String, port: Int, dir: String, username: String, auth: SSHAuthMethod)
        }
        
        let storage: Storage
        
        private init(_ storage: Storage) {
            self.storage = storage
        }
        
        /// Connection to a local console
        public static var local: Connection {
            return .init(.local(dir: Shell.DefaultDir))
        }
        
        
        /// Connection to a local console
        /// - Parameter dir: Current working directory
        public static func local(dir: String) -> Connection {
            return .init(.local(dir: dir))
        }
        
        
        /// SSH connection using username and password
        /// - Parameter host: SSH host
        /// - Parameter port: SSH port
        /// - Parameter DefaultDir: Current working directory, defaults to `~/`
        /// - Parameter username: Login username
        /// - Parameter password: Login password
        public static func ssh(host: String, port: Int = 22, dir: String = DefaultDir, username: String, password: String) -> Connection {
            let auth = SSHPassword(password)
            return .init(.ssh(host: host, port: port, dir: dir, username: username, auth: auth))
        }
        
        
        /// SSH connection using an alternative connection
        /// - Parameter host: SSH host
        /// - Parameter port: SSH port
        /// - Parameter DefaultDir: Current working directory, defaults to `~/`
        /// - Parameter username: Login username
        /// - Parameter auth: Authentication method
        public static func ssh(host: String, port: Int = 22, dir: String = DefaultDir, username: String, auth: SSHAuthMethod) -> Connection {
            return .init(.ssh(host: host, port: port, dir: dir, username: username, auth: auth))
        }
        
    }
    
    /// Default directory path
    public static var DefaultDir = "/"
    
    /// Output commands into ... output
    public var outputCommands: Bool = true
    
    /// Default output
    public var output: ((String) -> ())? = nil
    
    /// Event loop
    public let eventLoop: EventLoop
    
    /// Current executor
    public let executor: Executor
    
    /// Initializer
    /// - Parameter connection: Connection details
    /// - Parameter eventLoop: Event loop
    public init(_ connection: Connection, on eventLoop: EventLoop) throws {
        self.eventLoop = eventLoop
        switch connection.storage {
        case .local(dir: let dir):
            executor = try LocalExecutor(workDir: dir, on: eventLoop)
        case .ssh(host: let host, port: let port, dir: let dir, username: let user, auth: let auth):
            executor = try SSHExecutor(workDir: dir, host: host, port: port, username: user, auth: auth, on: eventLoop)
        }
    }
    
    /// Run bash command
    /// - Parameter command: bash command
    /// - Parameter output: Future containing an exit code
    public func run(bash command: String, output: ((String) -> ())? = nil) -> EventLoopFuture<String> {
        if outputCommands {
            output?("$ \(command)\n")
            self.output?(command + "\n")
        }
        return executor.run(bash: command) { text in
            output?(text)
            self.output?(text)
        }
    }
    
    /// Run command
    /// - Parameter command: Command
    /// - Parameter args: Arguments
    /// - Parameter output: Closure to output console text
    public func run(command: String, args: [String], output: ((String) -> ())? = nil) -> EventLoopFuture<String> {
        if outputCommands {
            output?("$ \(command) \(args.joined(separator: " "))\n")
            self.output?(command + "\n")
        }
        return executor.run(command: command, args: args) { text in
            output?(text)
            self.output?(text)
        }
    }
    
    /// Check if file exists
    /// - Parameter path: Path to the file
    public func exists(path: String) ->EventLoopFuture<Bool> {
        return executor.exists(path: path)
    }
    
    /// Set current working directory
    /// - Parameter path: Path
    public func cd(path: String) -> EventLoopFuture<Void> {
        return executor.cd(path: path)
    }
    
    /// Upload string as a file
    /// - Parameter string: Path to a local file
    /// - Parameter to: Destination path (including filename)
    public func upload(string: String, to path: String) -> EventLoopFuture<Void> {
        return executor.upload(file: string, to: path)
    }
    
    /// Upload data as a file
    /// - Parameter data: Path to a local file
    /// - Parameter to: Destination path (including filename)
    public func upload(data: Data, to path: String) -> EventLoopFuture<Void> {
        return upload(data: data, to: path)
    }
    
    /// Upload a file
    /// - Parameter file: Path to a local file
    /// - Parameter to: Destination path (including filename)
    public func upload(file: String, to path: String) -> EventLoopFuture<Void> {
        return upload(file: file, to: path)
    }
    
}
