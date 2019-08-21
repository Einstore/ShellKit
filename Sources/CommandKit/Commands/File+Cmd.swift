import Foundation
import NIO


extension Cmd {
    
    
    /// Return current or full path of a relative one
    /// - Parameter relativePath: Relative path to be converted into full
    public func pwd(relativePath path: String? = nil) -> EventLoopFuture<String> {
        if let path = path {
            return shell.run(bash: "TMP_P=$(pwd) && cd \(path.quoteEscape) && pwd && cd \"$TMP_P\"", output: nil).future.trimMap()
        } else {
            return shell.run(bash: "pwd", output: nil).future.trimMap()
        }
    }
    
    
    /// Return full home path
    public func home() -> EventLoopFuture<String> {
        return pwd(relativePath: "~")
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
        return shell.run(bash: "which \(command)", output: nil).future.trimMap()
    }
    
    /// Check is folder is empty
    /// - Parameter path: Command
    public func isEmpty(path: String) -> EventLoopFuture<Bool> {
        return shell.run(bash: "[ '$(ls -A /path/to/directory)' ] && echo 'not empty' || echo 'empty'", output: nil).future.map { output in
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
        return shell.run(bash: "cat \(path.quoteEscape)", output: nil).future
    }
    
    /// List files in a path
    /// - Parameter path: Path to file
    /// - Parameter flags: Flags
    /// - Parameter output: Future
    public func ls(path: String, flags: FlagsConvertible? = nil, output: ((String) -> ())? = nil) -> EventLoopFuture<String> {
        var flags = flags?.flags ?? ""
        if !flags.isEmpty {
            flags.append(contentsOf: " ")
        }
        return shell.run(bash: "ls \(flags)\(path.quoteEscape)", output: output).future
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
        return shell.run(bash: "rm \(flags) \(path.quoteEscape)", output: output).future
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
    public func mkdir(path: String, flags: FlagsConvertible? = [MkDir.p], output: ((String) -> ())? = nil) -> EventLoopFuture<String> {
        let flags = flags?.flags ?? ""
        #warning("There is a bug in FlagsConvertible ... something with the .description cycling")
        return shell.run(bash: "mkdir \(flags) \(path.quoteEscape)", output: output).future
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
