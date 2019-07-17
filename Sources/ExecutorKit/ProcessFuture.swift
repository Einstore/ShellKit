//
//  ProcessFuture.swift
//  
//
//  Created by Ondrej Rafaj on 17/07/2019.
//

import Foundation


public class ProcessFuture<Output> {
    
    public let future: EventLoopFuture<Output>
    public let cancel: (() -> ())
    
    public init(future: EventLoopFuture<Output>, cancel: @escaping (() -> ())) {
        self.cancel = cancel
        self.future = future
    }
    
}
