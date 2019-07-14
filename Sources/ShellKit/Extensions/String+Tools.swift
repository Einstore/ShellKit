//
//  String+Tools.swift
//  
//
//  Created by Ondrej Rafaj on 08/07/2019.
//

import Foundation


extension String {
    
    // MARK: Public interface
    
    public var quoteEscape: String {
        if !contains(" ") {
            return self
        }
        return "\"\(self)\""
    }
    
}
