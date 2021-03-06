import Foundation
import NIO


/// Executor protocol
public protocol Executor {
    
    var output: ((String) -> ())? { get set }
    
    var eventLoop: EventLoop { get }
    
    /// Run bash command
    /// - Parameter bash: bash command
    /// - Parameter output: Closure to output console text
    func run(bash: String, output: ((String) -> ())?) -> ProcessFuture<String>
    
    /// Run command
    /// - Parameter command: Command
    /// - Parameter args: Arguments
    /// - Parameter output: Closure to output console text
    func run(command: String, args: [String], output: ((String) -> ())?) -> ProcessFuture<String>
    
    /// Check if file exists
    /// - Parameter path: Path to the file
    func file(exists path: String) ->EventLoopFuture<Bool>
    
    /// Check if folder exists
    /// - Parameter path: Path to the file
    func folder(exists path: String) ->EventLoopFuture<Bool>
    
    /// Set current working directory
    /// - Parameter path: Path
    func cd(path: String) -> EventLoopFuture<Void>
    
    /// Upload a file
    /// - Parameter file: Path to a local file
    /// - Parameter to: Destination path (including filename)
    func upload(file: String, to: String) -> EventLoopFuture<Void>
    
    /// Upload data as a file
    /// - Parameter data: Path to a local file
    /// - Parameter to: Destination path (including filename)
    func upload(data: Data, to: String) -> EventLoopFuture<Void>
    
    /// Upload string as a file
    /// - Parameter string: Path to a local file
    /// - Parameter to: Destination path (including filename)
    func upload(string: String, to: String) -> EventLoopFuture<Void>
    
}


extension Executor {
    
    func run(bash: String) -> ProcessFuture<String> {
        return run(bash: bash, output: nil)
    }
    
    func run(command: String, args: [String]) -> ProcessFuture<String> {
        return run(command: command, args: args, output: nil)
    }
    
}
