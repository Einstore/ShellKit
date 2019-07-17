//
//  Install.swift
//  
//
//  Created by Ondrej Rafaj on 13/07/2019.
//

import WebErrorKit


/// Extension with commands
public struct Install {
    
    public enum InstallError: String, WebError {
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


extension Cmd {
    
    public var install: Install {
        return Install(shell)
    }
    
}
