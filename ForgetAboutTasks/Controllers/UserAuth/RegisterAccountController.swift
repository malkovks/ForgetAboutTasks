//
//  RegisterAccountViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 26.03.2023.
//

import UIKit
import SnapKit
import FirebaseAuth
//import FirebaseDatabase


class RegisterAccountViewController: UIViewController {
    
    private var isPasswordHidden: Bool = true
    
    private let indicator = UIActivityIndicatorView()
    
    //MARK: - UI views
    private let emailField: UITextField = {
       let field = UITextField()
        field.placeholder = " example@email.com"
        field.layer.borderWidth = 1
        field.textContentType = .emailAddress
        field.textColor = UIColor(named: "textColor")
        field.layer.cornerRadius = 12
        field.keyboardType = .emailAddress
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.clearButtonMode = .whileEditing
        field.autocapitalizationType = .none
        return field
    }()
    
    private let passwordField: UITextField = {
       let field = UITextField()
        field.placeholder = " Enter the password.."
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.layer.borderWidth = 1
        field.textContentType = .newPassword
        field.autocapitalizationType = .none
        field.passwordRules = UITextInputPasswordRules(descriptor: "No matter how and what")
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        return field
    }()
    
    private let secondPasswordField: UITextField = {
       let field = UITextField()
        field.placeholder = " Repeat password.."
        field.textColor = UIColor(named: "textColor")
        field.isSecureTextEntry = true
        field.layer.borderWidth = 1
        field.textContentType = .newPassword
        field.autocapitalizationType = .none
        field.passwordRules = UITextInputPasswordRules(descriptor: "No matter how and what")
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        return field
    }()
    
    private let userNameField: UITextField = {
       let field = UITextField()
        field.placeholder = " Enter your name"
        field.textColor = UIColor(named: "textColor")
        field.isSecureTextEntry = false
        field.layer.borderWidth = 1
        field.textContentType = .name
        field.autocapitalizationType = .words
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        return field
    }()
    
    private let isPasswordHiddenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        button.tintColor = UIColor(named: "navigationControllerColor")
        button.backgroundColor = UIColor(named: "launchBackgroundColor")
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let configureUserButton: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Create"
        button.configuration?.image = UIImage(systemName: "plus.circle.fill")?.withTintColor(UIColor(named: "launchBackgroundColor")!,renderingMode: .alwaysOriginal)
        button.configuration?.imagePadding = 8
        button.configuration?.imagePlacement = .trailing
        button.layer.cornerRadius = 8
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        button.configuration?.baseBackgroundColor = UIColor(named: "loginColor")
        button.tintColor = UIColor(named: "textColor")
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    //MARK: - Targets
    @objc private func didTapChangeVisible(){
        if isPasswordHidden {
            passwordField.isSecureTextEntry = false
            secondPasswordField.isSecureTextEntry = false
            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        } else {
            passwordField.isSecureTextEntry = true
            secondPasswordField.isSecureTextEntry = true
            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }
        isPasswordHidden = !isPasswordHidden
    }
    //Добавить функцию создания имени фамилии и базовых данных и привязки данных к аккаунту
    @objc private func didTapCreateNewAccount(){
        indicator.startAnimating()
        guard let mailField = emailField.text, !mailField.isEmpty,
              let firstPassword = passwordField.text, !firstPassword.isEmpty,
              let secondPassword = secondPasswordField.text, !secondPassword.isEmpty,
              let userName = userNameField.text, !userName.isEmpty else {
            alertError(text: "Enter text in all fields")
            return
        }
        if firstPassword.elementsEqual(secondPassword) {
            if secondPassword.count >= 8 {
                FirebaseAuth.Auth.auth().createUser(withEmail: mailField, password: secondPassword) { [weak self] _, error in
                    guard error == nil else { self?.alertError(text: "This account has already been created", mainTitle: "Error!"); return }
                    UserDefaults.standard.setValue(userName, forKey: "userName")
                    UserDefaults.standard.setValue(mailField, forKey: "userMail")
                    self?.view.window?.rootViewController?.dismiss(animated: true)
                    CheckAuth.shared.setupForAuth()
                    self?.indicator.stopAnimating()
                    do {
                        try! KeychainManager.save(service: "Firebase Auth", account: mailField, password: firstPassword.data(using: .utf8) ?? Data())
                    } catch {
                        self?.alertError(text: "Error saving in Keychain", mainTitle: "Error!")
                    }
                }
            } else {
                alertError(text: "Password must contains at least 8 symbols", mainTitle: "Warning")
                self.indicator.stopAnimating()
            }
            
        } else {
            alertError(text: "Passwords in both field aren't equal", mainTitle: "Warning")
            self.indicator.stopAnimating()
        }
    }
    //MARK: - Set up methods
    private func setupView(){
        setupConstraints()
        setupNavigationController()
        setupTargets()
        view.backgroundColor = UIColor(named: "launchBackgroundColor")
        emailField.becomeFirstResponder()
    }
    
    private func setupNavigationController(){
        title = "Create New Account"
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
    }
    
    private func setupTargets(){
        isPasswordHiddenButton.addTarget(self, action: #selector(didTapChangeVisible), for: .touchUpInside)
        configureUserButton.addTarget(self, action: #selector(didTapCreateNewAccount), for: .touchUpInside)
    }
    
}
//MARK: - Extensions
extension RegisterAccountViewController {
    private func setupConstraints(){
        view.addSubview(emailField)
        emailField.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-view.frame.size.height/4)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        view.addSubview(passwordField)
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        view.addSubview(secondPasswordField)
        secondPasswordField.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        view.addSubview(userNameField)
        userNameField.snp.makeConstraints { make in
            make.top.equalTo(secondPasswordField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        passwordField.rightView = isPasswordHiddenButton
        passwordField.rightViewMode = .whileEditing
        secondPasswordField.rightView = isPasswordHiddenButton
        secondPasswordField.rightViewMode = .whileEditing
        
        
        view.addSubview(configureUserButton)
        configureUserButton.snp.makeConstraints { make in
            make.top.equalTo(userNameField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(60)
            make.height.equalTo(40)
        }
        
        
    }
}
