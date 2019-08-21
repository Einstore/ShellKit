import Foundation
import NIO


extension Cmd {
    
    /// Who Am I (whoami)
    public func whoami() -> EventLoopFuture<String> {
        return shell.run(bash: "whoami", output: nil).future.trimMap()
    }
    
}
