import Foundation


extension String {
    
    // MARK: Public interface
    
    public var quoteEscape: String {
        if !contains(" ") {
            return self
        }
        return "\"\(self)\""
    }
    
}
