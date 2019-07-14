//
//  Install.swift
//  
//
//  Created by Ondrej Rafaj on 13/07/2019.
//

import Foundation


/// Extension with commands
public struct Install {
    
    public enum Error: Swift.Error {
        case unsupportedPlatform
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
