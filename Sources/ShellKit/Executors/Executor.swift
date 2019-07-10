//
//  Executor.swift
//  
//
//  Created by Ondrej Rafaj on 04/07/2019.
//

import Foundation
import NIO


/// Executor protocol
public protocol Executor {
    
    typealias Output = String
    
    /// Run bash command
    /// - Parameter bash: bash command
    /// - Parameter output: Future containing an exit code
    func run(bash: String, output: ((String) -> ())?) -> EventLoopFuture<Output>
    
    func run(command: String, args: [String], output: ((String) -> ())?) -> EventLoopFuture<Output>
    
    /// Check if file exists
    /// - Parameter path: Path to the file
    func exists(path: String) ->EventLoopFuture<Bool>
    
}
