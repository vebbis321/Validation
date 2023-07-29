//
//  ValidatorFactory.swift
//  Validation
//
//  Created by Vebjørn Daniloff on 7/29/23.
//

import Foundation

enum ValidatorFactory {
    static func validateForType(type: ValidatorType) -> Validatable {
        switch type {
        case .email:
            return EmailValidation()
        case .password:
            return PasswordValidation()
        case .name:
            return NameValidation()
        }
    }
}
