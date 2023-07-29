//
//  CustomTextField+ViewModel.swift
//  CustomTextField
//
//  Created by Vebjørn Daniloff on 7/25/23.
//

import UIKit

extension CustomTextField {
    struct ViewModel {
        
        var type: TextFieldType
        var placeholder: String?
        
        init(type: TextFieldType, placeholder: String? = nil) {
            self.type = type
            self.placeholder = placeholder == nil ? type.defaultPlaceholder() : placeholder
        }
        
        var isSecure: Bool {
            type == .password ? true : false
        }
        
        var keyboardType: UIKeyboardType {
            switch type {
            case .name, .password:
                return .default
            case .email:
                return .emailAddress
            }
        }
        
        var autoCap: UITextAutocapitalizationType {
            type == .name ? .words : .none
        }
    }
}
