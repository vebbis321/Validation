//
//  CustomTextField+Types.swift
//  CustomTextField
//
//  Created by Vebjørn Daniloff on 7/25/23.
//

import Foundation

extension CustomTextField {
    enum TextFieldType: String {
        case name
        case email
        case password
        
        func defaultPlaceholder() -> String {
            return "Enter your \(self.rawValue)..."
        }
    }
    
    
    
}
