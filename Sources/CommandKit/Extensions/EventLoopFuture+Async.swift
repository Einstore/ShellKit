import Foundation
import NIO


extension EventLoopFuture {
    
    public func completeQuietly() {
        whenComplete { _ in }
    }
    
    public func void() -> EventLoopFuture<Void> {
        return map { _ in Void() }
    }
    
}

extension EventLoopFuture where Value == String {
    
    func trimMap() -> EventLoopFuture<String> {
        return map {
            return $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
}
