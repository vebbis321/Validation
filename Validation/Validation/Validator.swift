//
//  Validator.swift
//  Validation
//
//  Created by Vebjørn Daniloff on 7/29/23.
//

import Foundation
import Combine

protocol Validator {
    func validateText(
        validationType: ValidatorType,
        publisher: AnyPublisher<String, Never>
    ) -> AnyPublisher<ValidationState, Never>
}

extension Validator {
    func validateText(
        validationType: ValidatorType,
        publisher: AnyPublisher<String, Never>
    ) -> AnyPublisher<ValidationState, Never> {
        let validator = ValidatorFactory.validateForType(type: validationType)
        return validator.validate(publisher: publisher)
    }
}
