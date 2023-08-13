//
//  LogInViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 25.03.2023.
//
import UIKit
import SnapKit
import FirebaseAuth
import Security


class LogInViewController: UIViewController {
    
    private var isPasswordHidden: Bool = true
    
    //MARK: - UI views
    private let emailField: UITextField = {
       let field = UITextField()
        field.placeholder = " example@email.com"
        field.layer.borderWidth = 1
        field.textContentType = .emailAddress
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.clearButtonMode = .whileEditing
        field.autocapitalizationType = .none
        return field
    }()
    
    private let passwordField: UITextField = {
       let field = UITextField()
        field.placeholder = " Enter the password.."
        field.isSecureTextEntry = true
        field.textContentType = .password
        field.layer.borderWidth = 1
        field.autocapitalizationType = .none
        field.passwordRules = UITextInputPasswordRules(descriptor: "No matter how and what")
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        return field
    }()
    
    private let isPasswordHiddenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = UIColor(named: "launchBackgroundColor")
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let configureUserButton: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Continue"
        button.layer.cornerRadius = 8
        button.configuration?.baseBackgroundColor = UIColor(named: "textColor")
        button.tintColor = UIColor(named: "textColor")
        return button
    }()
    
    private let resetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Forget password"
        button.configuration?.baseBackgroundColor = .clear
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        return button
    }()
    
    private let indicatorView = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConstraints()
    }
    //MARK: - Targets
    
    @objc private func didTapChangeVisible(){
        setupHapticMotion(style: .rigid)
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
        setupHapticMotion(style: .soft)
        indicatorView.startAnimating()
        guard let password = passwordField.text, !password.isEmpty else {
            alertError(text: "Enter email and password.\nIf You forget your personal data, try again later.", mainTitle: "Error login")
            return
        }
        guard let email = emailField.text, !email.isEmpty else {
            alertError(text: "Enter email and password.\nIf You forget your personal data, try again later.", mainTitle: "Error login")
            return
        }
        
        //get auth
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            
            guard error == nil,
                  let result = result else {
                self?.alertError(text: "Incorrect email or password.\nTry again!", mainTitle: "Error!")
                return
            }
            self?.view.window?.rootViewController?.dismiss(animated: true)
            self?.setupLoadingSpinner()
            UserDefaultsManager.shared.saveDataWithLogin(result: result)
            UserDefaultsManager.shared.setupForAuth()
            self?.indicatorView.stopAnimating()
        }
    }
    
    @objc private func didTapResetPassword(){
        let vc = ResetPasswordViewController()
        show(vc, sender: nil)
    }
    //MARK: - Set up methods
    private func setupView(){
        
        setupNavigationController()
        setupTargets()
        view.backgroundColor = UIColor(named: "launchBackgroundColor")
        emailField.becomeFirstResponder()
        
    }
    
    private func setupNavigationController(){
        title = "Log In"
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
    }
    
    private func setupTargets(){
        isPasswordHiddenButton.addTarget(self, action: #selector(didTapChangeVisible), for: .touchUpInside)
        configureUserButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        resetPasswordButton.addTarget(self, action: #selector(didTapResetPassword), for: .touchUpInside)
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
        
        view.addSubview(resetPasswordButton)
        resetPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(80)
            make.height.equalTo(30)
        }
        
        view.addSubview(configureUserButton)
        configureUserButton.snp.makeConstraints { make in
            make.top.equalTo(resetPasswordButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(60)
            make.height.equalTo(40)
        }
        
        
    }
}
