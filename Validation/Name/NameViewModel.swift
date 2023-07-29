//
//  NameViewModel.swift
//  Validation
//
//  Created by Vebjørn Daniloff on 7/29/23.
//

import Foundation
import Combine

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
