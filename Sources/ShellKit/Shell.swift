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
    
    public enum Error: Swift.Error {
        case badExitCode(command: String, exit: Int32, output: String)
    }
    
    /// Default directory path
    public static var DefaultDir = "/"
    
    public var outputCommands: Bool = true
    
    /// Default output
    public var output: ((String) -> ())? = nil
    
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
    
    /// Current executor
    public let executor: Executor
    
    /// Initializer
    /// - Parameter connection: Connection details
    /// - Parameter eventLoop: Event loop
    public init(_ connection: Connection, on eventLoop: EventLoop) throws {
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
    
}
