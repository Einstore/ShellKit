import NIO


extension ProcessFuture {
    
    @discardableResult
    public func wait() throws -> Output {
        return try future.wait()
    }
    
}
