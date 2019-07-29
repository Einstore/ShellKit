import Foundation


public struct Exit {
    
    public let terminationStatus: Int32
    
    public let terminationReason: Process.TerminationReason
    
    public init(terminationStatus: Int32, terminationReason: Process.TerminationReason) {
        self.terminationStatus = terminationStatus
        self.terminationReason = terminationReason
    }
    
}
