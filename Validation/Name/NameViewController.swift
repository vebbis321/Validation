//
//  ViewController.swift
//  CustomTextField
//
//  Created by Vebjørn Daniloff on 7/25/23.
//

import UIKit
import SwiftUI
import Combine

class NameViewController: UIViewController {
    
    // MARK: - Components
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var nameTextField = CustomTextField(viewModel: .init(type: .name, placeholder: "Custom placeholder"))
    lazy var emailTextField = CustomTextField(viewModel: .init(type: .email))
    lazy var passwordTextField = CustomTextField(viewModel: .init(type: .password))

    // MARK: - Properties
    private let viewModel = NameViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    // MARK: - setup
    private func setup() {
        view.backgroundColor = .white
        
        vStack.addArrangedSubview(nameTextField)
        vStack.addArrangedSubview(emailTextField)
        vStack.addArrangedSubview(passwordTextField)
        
        view.addSubview(vStack)
        
        vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        
        vStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        vStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
    
    
    func moveToNExtScreen() {
        nameTextField.validationState == .valid
    }
}



struct MyTestVC_Previews: PreviewProvider {
    static var previews: some View {
        NameViewController().showPreview()
    }
}
