import WebErrorKit
import ExecutorKit


/// Extension with commands
public struct Install {
    
    public enum InstallError: String, WebError {
        case unsupportedPlatform
        
        public var statusCode: Int {
            return 412
        }
        
    }
    
    let shell: MasterExecutor
    
    init(_ shell: MasterExecutor) {
        self.shell = shell
    }
    
}


extension Cmd {
    
    public var install: Install {
        return Install(shell)
    }
    
}
