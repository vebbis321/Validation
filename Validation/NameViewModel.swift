//
//  NameViewModel.swift
//  Validation
//
//  Created by Vebjørn Daniloff on 7/29/23.
//

import Foundation
import Combine

enum ValidationState: Equatable {
    case idle
    case error(ErrorState)
    case valid
    
    enum ErrorState: Equatable {
        case empty
        case invalidEmail
        case toShortPassword
        case passwordNeedsNum
        case passwordNeedsLetters
        case nameCantContainNumbers
        case nameCantContainSpecialChars
        case toShortName
        case custom(String)
        
        var description: String {
            switch self {
            case .empty:
                return "Field is empty."
            case .invalidEmail:
                return "Invalid email."
            case .toShortPassword:
                return "Password is to short."
            case .passwordNeedsNum:
                return "Password needs numbers."
            case .passwordNeedsLetters:
                return "Password needs letters."
            case .nameCantContainNumbers:
                return "Name can't contain any numbers."
            case .nameCantContainSpecialChars:
                return "Name can't contain special characters."
            case .toShortName:
                return "Name is to short."
            case .custom(let text):
                return text
            }
        }
    }
}

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

extension Publisher where Self.Output == String, Failure == Never {
    func validateText(
        validationType: ValidatorType
    ) -> AnyPublisher<ValidationState, Never> {
        let validator = ValidatorFactory.validateForType(type: validationType)
        return validator.validate(publisher: self.eraseToAnyPublisher())
    }
}

enum ValidatorType: String {
    case email
    case password
    case name
}

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

protocol Validatable {
    func validate(publisher: AnyPublisher<String, Never>) -> AnyPublisher<ValidationState, Never>
}

extension Validatable {
    func isEmpty(publisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        publisher
            .map { $0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    func isToShort(publisher: AnyPublisher<String, Never>, count: Int) -> AnyPublisher<Bool, Never> {
        publisher
            .map { !($0.count >= count) }
            .eraseToAnyPublisher()
    }
    
    func hasNumbers(publisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        publisher
            .map { $0.hasNumbers() }
            .eraseToAnyPublisher()
    }
    
    func hasSpecialChars(publisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        publisher
            .map { $0.hasSpecialCharacters() }
            .eraseToAnyPublisher()
    }
    
    func isValidEmail(publisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        publisher
            .map { $0.isValidEmail() }
            .eraseToAnyPublisher()
    }
    
    func hasLetters(publisher: AnyPublisher<String, Never>) -> AnyPublisher<Bool, Never> {
        publisher
            .map { $0.contains(where: { $0.isLetter} ) }
            .eraseToAnyPublisher()
    }
}

struct NameValidation: Validatable {
    func validate(publisher: AnyPublisher<String, Never>) -> AnyPublisher<ValidationState, Never> {
        
        Publishers.CombineLatest4(
            isEmpty(publisher: publisher),
            isToShort(publisher: publisher, count: 2),
            hasNumbers(publisher: publisher),
            hasSpecialChars(publisher: publisher)
        )
        .removeDuplicates(by: { prev, curr in
            prev == curr
        })
        .map {
            if $0.0 { return .error(.empty) }
            if $0.1 { return .error(.toShortName) }
            if $0.2 { return .error(.nameCantContainNumbers) }
            if $0.3 { return .error(.nameCantContainSpecialChars) }
            return .valid
        }
        .eraseToAnyPublisher()
    }
}

struct EmailValidation: Validatable {
    func validate(publisher: AnyPublisher<String, Never>) -> AnyPublisher<ValidationState, Never> {
        
        Publishers.CombineLatest(
            isEmpty(publisher: publisher),
            isValidEmail(publisher: publisher)
        )
        .removeDuplicates(by: { prev, curr in
            prev == curr
        })
        .map {
            if $0.0 { return .error(.empty) }
            if !$0.1 { return .error(.invalidEmail) }
            return .valid
        }
        .eraseToAnyPublisher()
    }
}

struct PasswordValidation: Validatable {
    func validate(publisher: AnyPublisher<String, Never>) -> AnyPublisher<ValidationState, Never> {
        
        Publishers.CombineLatest4(
            isEmpty(publisher: publisher),
            isToShort(publisher: publisher, count: 6),
            hasNumbers(publisher: publisher),
            hasLetters(publisher: publisher)
        )
        .removeDuplicates(by: { prev, curr in
            prev == curr
        })
        .map {
            if $0.0 { return .error(.empty) }
            if $0.1 { return .error(.toShortPassword) }
            if !$0.2 { return .error(.passwordNeedsNum) }
            if !$0.3 { return .error(.passwordNeedsLetters) }
            return .valid
        }
        .eraseToAnyPublisher()
    }
}

final class NameViewModel {
    
    enum NameState: Equatable {
        case idle
        case error(ErrorState)
        case success
        
        enum ErrorState {
            case empty
            case toShort
            case numbers
            case specialChars
            
            var description: String {
                switch self {
                case .empty:
                    return "Field can't be empty."
                case .toShort:
                    return "Name is to short."
                case .numbers:
                    return "Name can't contain any numbers."
                case .specialChars:
                    return "Name can't contain special characters."
                }
            }
        }
    }
    
    @Published var firstName = ""
    @Published var state: NameState = .idle
    
 
    var isEmpty: AnyPublisher<Bool, Never> {
        $firstName
            .map { $0.isEmpty }
            .eraseToAnyPublisher()
    }
    
    var isToShort: AnyPublisher<Bool, Never> {
        $firstName
            .map { !($0.count >= 2) }
            .eraseToAnyPublisher()
    }
    
    var hasNumbers: AnyPublisher<Bool, Never> {
        $firstName
            .map { $0.hasNumbers() }
            .eraseToAnyPublisher()
    }
    
    var hasSpecialChars: AnyPublisher<Bool, Never> {
        $firstName
            .map { $0.hasSpecialCharacters() }
            .eraseToAnyPublisher()
    }
    
    func startValidation() {
        guard state == .idle else { return }
        
        Publishers.CombineLatest4(
            isEmpty,
            isToShort,
            hasNumbers,
            hasSpecialChars
        ).map {
            if $0.0 { return .error(.empty) }
            if $0.1 { return .error(.toShort) }
            if $0.2 { return .error(.numbers) }
            if $0.3 { return .error(.specialChars) }
            return .success
        }
        .assign(to: &$state)
    }
}
