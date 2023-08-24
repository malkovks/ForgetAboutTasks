//
//  ChangePasswordController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 22.08.2023.
//

import UIKit
import Firebase


class ChangePasswordController: UIViewController {
    
    private let accountMail: String
    
    init(account: String) {
        self.accountMail = account
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.font = .setMainLabelFont()
        label.text = "Set new password"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let oldPasswordField: UITextField = {
       let field = UITextField()
        field.placeholder = " Enter the password.."
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.layer.borderWidth = 1
        field.textContentType = .oneTimeCode
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.returnKeyType = .continue
        field.tag = 0
        return field
    }()
    
    private let firstNewPasswordTextField: UITextField = {
       let field = UITextField()
        field.placeholder = " Enter the password.."
        field.passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: lower; minlength: 8;")
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.layer.borderWidth = 1
        field.textContentType = .oneTimeCode
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.returnKeyType = .continue
        field.tag = 1
        return field
    }()
    
    private let secondNewPasswordTextField: UITextField = {
       let field = UITextField()
        field.placeholder = " Enter the password.."
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.layer.borderWidth = 1
        field.textContentType = .oneTimeCode
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.returnKeyType = .continue
        field.tag = 2
        return field
    }()
    
    private let confirmNewPasswordButton: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Reset"
        button.layer.cornerRadius = 8
        button.configuration?.baseBackgroundColor = UIColor(named: "textColor")
        button.tintColor = UIColor(named: "textColor")
        return button
    }()
    
    private let indicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //MARK: - Target methods
    @objc private func didTapConfirmChangePassword(sender: UIButton){
        indicator.startAnimating()
        view.alpha = 0.8
        checkPasswordFields()
    }
    //MARK: - Setup methods
    private func setupView(){
        setupNavigationController()
        setupTextFields()
        setupConstraints()
        setupIndicator()
        view.backgroundColor = UIColor(named: "launchBackgroundColor")
        confirmNewPasswordButton.addTarget(self, action: #selector(didTapConfirmChangePassword), for: .touchUpInside)
    }
    
    private func setupNavigationController(){
        tabBarController?.tabBar.isHidden = true
        title = "Change password"
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
    }
    
    private func setupTextFields(){
        oldPasswordField.becomeFirstResponder()
        let fields = [oldPasswordField,firstNewPasswordTextField,secondNewPasswordTextField]
        fields.forEach { textField in
            textField.delegate = self
        }
    }
    
    private func setupIndicator(){
        view.addSubview(indicator)
        indicator.center = view.center
    }
    
    
    private func checkPasswordFields(){
        guard let oldPassword = oldPasswordField.text else { alertError(text: "Enter correct old password", mainTitle: "Error"); return }
        let authCredential = EmailAuthProvider.credential(withEmail: accountMail, password: oldPassword)
        if let password = firstNewPasswordTextField.text, !password.isEmpty,
           let secondPassword = secondNewPasswordTextField.text, !secondPassword.isEmpty,
           password == secondPassword {
            Auth.auth().currentUser?.reauthenticate(with: authCredential, completion: { [weak self] _, error in
                if let error = error {
                    self?.alertError(text: error.localizedDescription)
                    self?.indicator.stopAnimating()
                } else {
                    Auth.auth().currentUser?.updatePassword(to: password, completion: { error in
                        if let error = error {
                            self?.alertError(text: error.localizedDescription)
                            self?.indicator.stopAnimating()
                        } else {
                            self?.indicator.stopAnimating()
//                            self?.alertError(text: "Password was changed successfully", mainTitle: "Success!")
                            self?.alertDismissed(view: (self?.view)!, title: "Password was changed successfully")
                            DispatchQueue.main.async {
                                if let nav = self?.navigationController {
                                    nav.popViewController(animated: true)
                                } else {
                                    print("Error")
                                }
                            }
                        }
                    })
                }
            })
        } else {
            alertError(text: "Password is not equal or valid. Try again", mainTitle: "Ошибка")
            indicator.stopAnimating()
        }
        view.alpha = 1
    }
    
    private func clearTextFields(){
        firstNewPasswordTextField.text = ""
        secondNewPasswordTextField.text = ""
    }

}
//MARK: - Delegates and constraints
extension ChangePasswordController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }
        if textField == firstNewPasswordTextField {
            firstNewPasswordTextField.resignFirstResponder()
            secondNewPasswordTextField.becomeFirstResponder()
            return true
        } else if textField == secondNewPasswordTextField {
            if text.isPasswordValidation(text){
                textField.resignFirstResponder()
                view.alpha = 0.8
                checkPasswordFields()
                return true
            } else {
                alertError(text: "Password is not valid")
                clearTextFields()
                return false
            }
        } else {
            return false
        }
        
    }
}

extension ChangePasswordController {
    private func setupConstraints(){
        view.addSubview(oldPasswordField)
        oldPasswordField.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-view.frame.size.height/4)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        view.addSubview(passwordLabel)
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(oldPasswordField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        view.addSubview(firstNewPasswordTextField)
        firstNewPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        view.addSubview(secondNewPasswordTextField)
        secondNewPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(firstNewPasswordTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        view.addSubview(confirmNewPasswordButton)
        confirmNewPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(secondNewPasswordTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        
    }
}
