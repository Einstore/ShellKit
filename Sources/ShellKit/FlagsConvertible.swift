import Foundation


public protocol FlagsConvertible {
    var flags: String { get }
}


extension String: FlagsConvertible {
    
    public var flags: String {
        return self
    }
    
}


extension Optional: FlagsConvertible where Wrapped: FlagsConvertible {
    
    public var flags: String {
        return ""
    }
    
}
