//
//  File+Handling.swift
//  
//
//  Created by Ondrej Rafaj on 08/07/2019.
//

import Foundation
import NIO


extension Shell {
    
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
        return run(bash: "rm \(flags) \(path.quoteEscape)", output: output)
    }
    
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
    public func mkdir(path: String, flags: FlagsConvertible? = [MkDir.p], output: ((String) -> ())? = nil) -> EventLoopFuture<Output> {
        let flags = flags?.flags ?? ""
        return run(bash: "mkdir \(flags) \(path.quoteEscape)", output: output)
    }
    
    
    /// Check if file exists
    /// - Parameter path: Path to the file
    public func exists(path: String) ->EventLoopFuture<Bool> {
        return executor.exists(path: path)
    }
    
}
