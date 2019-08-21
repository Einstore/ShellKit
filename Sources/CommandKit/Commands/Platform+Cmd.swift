import Foundation
import NIO


extension Cmd {
    
    public enum Os {
        
        case macOs
        
        case linux
        
        case cygwin
        
        case minGW
        
        case other(String)
        
        public static var command: String {
            return "uname -s"
        }
        
        public static func parse(_ string: String) -> Os {
            let string = string
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            switch true {
            case string == "darwin":
                return .macOs
            case string == "linux":
                return .linux
            case string == "cigwin":
                return .cygwin
            case string == "mingw":
                return .minGW
            default:
                return .other(string)
            }
        }
        
    }
    
    /// Get target platform
    public func os() -> EventLoopFuture<Os> {
        return platform().map { output in
            return Os.parse(output)
        }
    }
    
    /// Get target platform
    public func platform() -> EventLoopFuture<String> {
        return shell.run(bash: Os.command, output: nil).future.trimMap()
    }
    
}
