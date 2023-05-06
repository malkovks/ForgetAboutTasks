//
//  RegisterAccountViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 26.03.2023.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase


class RegisterAccountViewController: UIViewController {
    
    private var isPasswordHidden: Bool = true
    
    //MARK: - UI views
    private let emailField: UITextField = {
       let field = UITextField()
        field.placeholder = " example@email.com"
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 12
        field.layer.borderColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        field.clearButtonMode = .whileEditing
        field.autocapitalizationType = .none
        return field
    }()
    
    private let passwordField: UITextField = {
       let field = UITextField()
        field.placeholder = " Enter the password.."
        field.isSecureTextEntry = true
        field.layer.borderWidth = 1
        field.autocapitalizationType = .none
        field.passwordRules = UITextInputPasswordRules(descriptor: "No matter how and what")
        field.layer.cornerRadius = 12
        field.layer.borderColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        return field
    }()
    
    private let secondPasswordField: UITextField = {
       let field = UITextField()
        field.placeholder = " Repeat password.."
        field.isSecureTextEntry = true
        field.layer.borderWidth = 1
        field.autocapitalizationType = .none
        field.passwordRules = UITextInputPasswordRules(descriptor: "No matter how and what")
        field.layer.cornerRadius = 12
        field.layer.borderColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        return field
    }()
    
    private let userNameField: UITextField = {
       let field = UITextField()
        field.placeholder = " Enter your name"
        field.isSecureTextEntry = false
        field.layer.borderWidth = 1
        field.autocapitalizationType = .words
        field.layer.cornerRadius = 12
        field.layer.borderColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        return field
    }()
    
    private let isPasswordHiddenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let isPasswordHiddenButtonSecond: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let configureUserButton: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Create.."
        button.configuration?.image = UIImage(systemName: "plus.circle.fill")?.withTintColor(.secondarySystemBackground,renderingMode: .alwaysOriginal)
        button.configuration?.imagePadding = 8
        button.layer.cornerRadius = 8
        button.backgroundColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        button.tintColor = .systemBackground
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    //MARK: - Targets
    @objc private func didTapBack(){
        self.dismiss(animated: true)
    }
    
    @objc private func didTapChangeVisible(){
        if isPasswordHidden {
            passwordField.isSecureTextEntry = false
            secondPasswordField.isSecureTextEntry = false
            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
            isPasswordHiddenButtonSecond.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        } else {
            passwordField.isSecureTextEntry = true
            secondPasswordField.isSecureTextEntry = true
            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            isPasswordHiddenButtonSecond.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }
        isPasswordHidden = !isPasswordHidden
    }
    //Добавить функцию создания имени фамилии и базовых данных и привязки данных к аккаунту
    @objc private func didTapCreateNewAccount(){
        guard let mailField = emailField.text, !mailField.isEmpty,
              let firstPassword = passwordField.text, !firstPassword.isEmpty,
              let secondPassword = secondPasswordField.text, !secondPassword.isEmpty,
              let userName = userNameField.text, !userName.isEmpty else {
            setupAlert(title: "Error!", subtitle: "Some of the text fields is empty.\nEnter value in all fields")
            return
        }
        if firstPassword.elementsEqual(secondPassword) {
            print("Equal and creating new account")
            if secondPassword.count >= 8 {
                FirebaseAuth.Auth.auth().createUser(withEmail: mailField, password: secondPassword) { result, error in
                    guard error == nil, let result = result else { self.setupAlert(); return }
                    
                    let ref = Database.database().reference().child("users")
                    ref.child(result.user.uid).updateChildValues(["name" : userName,"email": mailField]) { error, _ in
                        if error != nil {
                            print("Error saving data")
                        }
                    }
                    UserDefaults.standard.setValue(userName, forKey: "userName")
                    UserDefaults.standard.setValue(mailField, forKey: "userMail")
                    self.view.window?.rootViewController?.dismiss(animated: true)
                    CheckAuth.shared.setupForAuth()
                    
                }
            } else {
                setupAlert(title: "Alert!", subtitle: "Password must contains at least 8 letters.\nChange size of your password!")
            }
            
        } else {
            setupAlert(title: "Error!", subtitle: "Password is not equal.\nTry again!")
        }
    }
    //MARK: - Set up methods
    private func setupView(){
        setupConstraints()
        setupNavigationController()
        setupTargets()
        view.backgroundColor = .secondarySystemBackground
        emailField.becomeFirstResponder()
    }
    
    private func setupNavigationController(){
        title = "Create New Account"
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "return"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapBack))
    }
    
    private func setupTargets(){
        isPasswordHiddenButton.addTarget(self, action: #selector(didTapChangeVisible), for: .touchUpInside)
        isPasswordHiddenButtonSecond.addTarget(self, action: #selector(didTapChangeVisible), for: .touchUpInside)
        configureUserButton.addTarget(self, action: #selector(didTapCreateNewAccount), for: .touchUpInside)
    }
    
    private func setupAlert(title: String = "Error",subtitle: String = "Something goes wrong!"){
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
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
        
        view.addSubview(isPasswordHiddenButton)
        isPasswordHiddenButton.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(25)
            make.trailing.equalToSuperview().inset(25)
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
        
        view.addSubview(isPasswordHiddenButtonSecond)
        isPasswordHiddenButtonSecond.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(25)
            make.trailing.equalToSuperview().inset(25)
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
        
        view.addSubview(configureUserButton)
        configureUserButton.snp.makeConstraints { make in
            make.top.equalTo(userNameField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(60)
            make.height.equalTo(40)
        }
        
        
    }
}
