//
//  Publisher+Extensions.swift
//  Validation
//
//  Created by Vebjørn Daniloff on 7/29/23.
//

import Foundation
import Combine

extension Publisher where Self.Output == String, Failure == Never {
    func validateText(
        validationType: ValidatorType
    ) -> AnyPublisher<ValidationState, Never> {
        let validator = ValidatorFactory.validateForType(type: validationType)
        return validator.validate(publisher: self.eraseToAnyPublisher())
    }
}
