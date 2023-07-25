//
//  CustomTextField.swift
//  CustomTextField
//
//  Created by Vebjørn Daniloff on 7/25/23.
//

import UIKit

final class CustomTextField: UIView {
    // MARK: - Components
    lazy var textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.textColor = .label
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var textFieldBackgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black.withAlphaComponent(0.125)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    private var viewModel: ViewModel
    private var focusState: FocusState = .inActive {
        didSet {
            focusStateChanged()
        }
    }
    
    // MARK: - LifeCycle
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup
    private func setup() {
        textField.isSecureTextEntry = viewModel.isSecure
        textField.placeholder = viewModel.placeholder
        textField.keyboardType = viewModel.keyboardType
        textField.autocapitalizationType = viewModel.autoCap
        
        addSubview(textFieldBackgroundView)
        textFieldBackgroundView.addSubview(textField)
        
        textFieldBackgroundView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        textFieldBackgroundView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        textFieldBackgroundView.topAnchor.constraint(equalTo: textField.topAnchor, constant: -9).isActive = true
        textFieldBackgroundView.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 9).isActive = true
        
        textField.leftAnchor.constraint(equalTo: textFieldBackgroundView.leftAnchor, constant: 6).isActive = true
        textField.rightAnchor.constraint(equalTo: textFieldBackgroundView.rightAnchor).isActive = true
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: textFieldBackgroundView.heightAnchor).isActive = true
    }
    
    // MARK: - Methods
    private func focusStateChanged() {
        textFieldBackgroundView.layer.borderColor = focusState.borderColor
        textFieldBackgroundView.layer.borderWidth = focusState.borderWidth
    }
}

// MARK: - UITextFieldDelegate
extension CustomTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        focusState = .active
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        focusState = .inActive
    }
}
