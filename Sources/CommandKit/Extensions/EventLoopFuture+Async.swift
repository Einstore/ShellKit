//
//  EventLoopFuture+Async.swift
//  
//
//  Created by Ondrej Rafaj on 13/07/2019.
//

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
        return map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
}
