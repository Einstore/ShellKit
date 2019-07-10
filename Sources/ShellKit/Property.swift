//
//  Property.swift
//  
//
//  Created by Ondrej Rafaj on 08/07/2019.
//

import Foundation


public protocol Property: LosslessStringConvertible, RawRepresentable, FlagsConvertible { }

extension Property {
    
    public init?(_ description: String) {
        return nil
    }
    
    public var description: String {
        return String(self)
    }
    
    public var flags: String {
        return "-\(description)"
    }
    
}


extension Array: FlagsConvertible where Element: Property {
    
    var strings: [String] {
        map { $0.description }
    }
    
    public var flags: String {
        guard count > 0 else {
            return ""
        }
        return "-\(self.strings.joined())"
    }
    
}
