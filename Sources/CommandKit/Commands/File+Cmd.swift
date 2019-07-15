//
//  File+Cmd.swift
//  
//
//  Created by Ondrej Rafaj on 08/07/2019.
//

import Foundation
import NIO


extension Cmd {
    
    /// Return current path
    public func pwd() -> EventLoopFuture<String> {
        return shell.run(bash: "pwd").trimMap()
    }
    
    /// Set current working directory
    /// - Parameter path: Path
    ///    - Note: Convenience method for `shell.cd(path: String)`
    public func cd(path: String) -> EventLoopFuture<Void> {
        return shell.cd(path: path)
    }
    
    /// Return a command path if exists
    /// - Parameter command: Command
    public func which(_ command: String) -> EventLoopFuture<String> {
        return shell.run(bash: "which \(command)").trimMap()
    }
    
    /// Check is folder is empty
    /// - Parameter path: Command
    public func isEmpty(path: String) -> EventLoopFuture<Bool> {
        return shell.run(bash: "[ '$(ls -A /path/to/directory)' ] && echo 'not empty' || echo 'empty'").map { output in
            return output.trimmingCharacters(in: .whitespacesAndNewlines) == "empty"
        }
    }
    
    /// Check is command exists
    /// - Parameter command: Command
    public func exists(command: String) -> EventLoopFuture<Bool> {
        return shell.cmd.which(command).map { !$0.isEmpty }.recover { _ in false }
    }
    
    /// Return content of a file as a string
    /// - Parameter path: Path to file
    public func cat(path: String) -> EventLoopFuture<String> {
        return shell.run(bash: "cat \(path.quoteEscape)")
    }
    
    /// List files in a path
    /// - Parameter path: Path to file
    /// - Parameter flags: Flags
    /// - Parameter output: Future
    public func ls(path: String, flags: FlagsConvertible? = nil, output: ((String) -> ())? = nil) -> EventLoopFuture<String> {
        let flags = flags?.flags ?? ""
        return shell.run(bash: "ls \(flags) \(path.quoteEscape)", output: output)
    }
    
    /// Remove flags
    public enum Rm: String, Property {        
        
        /// Recursive
        case r
        
        /// Force delete
        case f
        
    }
    
    /// Remove file or folder at path
    /// - Parameter path: Path
    /// - Parameter flags: Flags `Shell.Rm` or string in a `-f` format
    /// - Parameter output: Future
    public func rm(path: String, flags: FlagsConvertible? = nil, output: ((String) -> ())? = nil) -> EventLoopFuture<String> {
        let flags = flags?.flags ?? ""
        return shell.run(bash: "rm \(flags) \(path.quoteEscape)", output: output)
    }
    
    /// Make dir flags
    public enum MkDir: String, Property {
        
        /// Create full path
        case p
        
        /// Verbose
        case v
        
    }
    
    /// Create a folder structure
    /// - Parameter path: Path
    /// - Parameter flags: Flags (-p is default)
    /// - Parameter output: Future
    public func mkdir(path: String, flags: FlagsConvertible? = [MkDir.p], output: ((String) -> ())? = nil) -> EventLoopFuture<Shell.Output> {
        let flags = flags?.flags ?? ""
        return shell.run(bash: "mkdir \(flags) \(path.quoteEscape)", output: output)
    }
    
    /// Check if file exists
    /// - Parameter path: Path to the file
    public func file(exists path: String) ->EventLoopFuture<Bool> {
        return shell.executor.file(exists: path)
    }
    
    /// Check if folder exists
    /// - Parameter path: Path to the folder
    public func folder(exists path: String) ->EventLoopFuture<Bool> {
        return shell.executor.folder(exists: path)
    }
    
}
