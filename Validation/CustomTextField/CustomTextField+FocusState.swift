//
//  CustomTextField+FocusState.swift
//  CustomTextField
//
//  Created by Vebjørn Daniloff on 7/25/23.
//

import UIKit

extension CustomTextField {
    enum FocusState {
        case active
        case inActive
        
        var borderColor: CGColor? {
            self == .active ? UIColor.black.withAlphaComponent(0.6).cgColor : .none
        }
        
        var borderWidth: CGFloat {
            self == .active ? 1 : 0
        }
    }
}
