//
//  LogInViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 25.03.2023.
//
import UIKit
import SnapKit
import FirebaseAuth


class LogInViewController: UIViewController {
    
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
    
    private let isPasswordHiddenButton: UIButton = {
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
        button.configuration?.title = "Continue"
        button.configuration?.image = UIImage(systemName: "arrowshape.right.fill")?.withTintColor(.secondarySystemBackground,renderingMode: .alwaysOriginal)
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
            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        } else {
            passwordField.isSecureTextEntry = true
            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }
        isPasswordHidden = !isPasswordHidden
    }
    //при входе в аккаунт выгружать также имя фамилию и прочее
    @objc private func didTapContinue(){
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            setupAlert(title: "Error Log In!", subtitle: "Enter email and password.\nIf You forget your personal data, try again later.")
            return
        }
        
        //get auth
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            
            guard error == nil else {
                self?.setupAlert(subtitle: "Account wasn't Found!\nPlease, try again!")
                return
            }
            self?.view.window?.rootViewController?.dismiss(animated: true)
            self?.setupLoadingSpinner()
            UserDefaults.standard.setValue(email, forKey: "userMail")
            CheckAuth.shared.setupForAuth()
            
            
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
    
    private func setupAlert(title: String = "Error!",subtitle: String ){
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert,animated: true)
    }
    
    private func setupNavigationController(){
        title = "Log In"
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "return"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapBack))
    }
    
    private func setupTargets(){
        isPasswordHiddenButton.addTarget(self, action: #selector(didTapChangeVisible), for: .touchUpInside)
        configureUserButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    }
    
    private func showRegisterAccount(){
        let vc = RegisterAccountViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .flipHorizontal
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
}
//MARK: - Extensions
extension LogInViewController {
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
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        passwordField.rightView = isPasswordHiddenButton
        passwordField.rightViewMode = .whileEditing
        
        view.addSubview(configureUserButton)
        configureUserButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(60)
            make.height.equalTo(40)
        }
        
        
    }
}
