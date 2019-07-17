//
//  Cmd.swift
//  
//
//  Created by Ondrej Rafaj on 13/07/2019.
//

import Foundation
import WebErrorKit


/// Extension with commands
public struct Cmd {
    
    public enum CmdError: String, WebError {
        
        case unsupportedPlatform
        
        public var statusCode: Int {
            return 412
        }
        
    }
    
    let shell: Shell
    
    init(_ shell: Shell) {
        self.shell = shell
    }
    
}


extension Shell {
    
    public var cmd: Cmd {
        return Cmd(self)
    }
    
}
