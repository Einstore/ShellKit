//
//  FlagsConvertible.swift
//  
//
//  Created by Ondrej Rafaj on 08/07/2019.
//

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
