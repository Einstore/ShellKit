//
//  File.swift
//  
//
//  Created by Ondrej Rafaj on 15/07/2019.
//

import Foundation
import NIO


extension Cmd {
    
    /// Who Am I (whoami)
    public func whoami() -> EventLoopFuture<String> {
        return shell.run(bash: "whoami").trimMap()
    }
    
}
