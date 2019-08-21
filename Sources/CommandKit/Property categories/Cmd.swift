import Foundation
import ExecutorKit
import WebErrorKit


/// Extension with commands
public struct Cmd {
    
    public enum CmdError: String, WebError {
        
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


extension MasterExecutor {
    
    public var cmd: Cmd {
        return Cmd(self)
    }
    
}
