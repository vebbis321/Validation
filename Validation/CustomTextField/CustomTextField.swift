//
//  CustomTextField.swift
//  CustomTextField
//
//  Created by Vebjørn Daniloff on 7/25/23.
//

import UIKit
import Combine

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
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .red
        label.font = .preferredFont(forTextStyle: .footnote)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var expandingVstack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    private var viewModel: ViewModel
    private var focusState: FocusState = .inActive {
        didSet {
            focusStateChanged()
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    @Published var validationState: ValidationState = .idle
    
    // MARK: - LifeCycle
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setup()
        listen()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        startValidation()
    }
    
    // MARK: - setup
    private func setup() {
        textField.isSecureTextEntry = viewModel.isSecure
        textField.placeholder = viewModel.placeholder
        textField.keyboardType = viewModel.keyboardType
        textField.autocapitalizationType = viewModel.autoCap
        
        textFieldBackgroundView.addSubview(textField)
        addSubview(expandingVstack)
       
        expandingVstack.addArrangedSubview(textFieldBackgroundView)
        expandingVstack.addArrangedSubview(errorLabel)
        
        textFieldBackgroundView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        textFieldBackgroundView.topAnchor.constraint(equalTo: textField.topAnchor, constant: -9).isActive = true
        textFieldBackgroundView.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 9).isActive = true
        
        textField.leftAnchor.constraint(equalTo: textFieldBackgroundView.leftAnchor, constant: 6).isActive = true
        textField.rightAnchor.constraint(equalTo: textFieldBackgroundView.rightAnchor, constant: -6).isActive = true
        
        errorLabel.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalTo: expandingVstack.heightAnchor).isActive = true
    }
    
    // MARK: - Methods
    private func focusStateChanged() {
        textFieldBackgroundView.layer.borderColor = focusState.borderColor
        textFieldBackgroundView.layer.borderWidth = focusState.borderWidth
    }
    
    func validationStateChanged(state: ValidationState) {
        switch state {
        case .idle:
            break
        case .error(let errorState):
            errorLabel.text = errorState.description
            errorLabel.isHidden = false
        case .valid:
            errorLabel.text = nil
            errorLabel.isHidden = true
        }
    }
    
    private func listen() {
        $validationState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.validationStateChanged(state: state)
            }.store(in: &subscriptions)
    }
}

// MARK: - Validator
extension CustomTextField: Validator {
    private func startValidation() {
        guard validationState == .idle, let validationType = ValidatorType(rawValue: viewModel.type.rawValue) else { return }
        
        textField.textPublisher()
            .removeDuplicates()
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .validateText(validationType: validationType)
            .assign(to: &$validationState)
        
        NotificationCenter.default.post(
            name: UITextField.textDidChangeNotification,
            object: textField
        )
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
