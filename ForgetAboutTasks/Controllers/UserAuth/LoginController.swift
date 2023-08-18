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

enum LoginConnectionStatus {
    case successConnectionAuthorization
    case successAuthorizationWithoutInternet
    case unsuccessfullyAuthorization
}


class LogInViewController: UIViewController {
    
    private var isPasswordHidden: Bool = true
    
    //MARK: - UI views
    private let emailField: UITextField = {
       let field = UITextField()
        field.tag = 0
        field.placeholder = " example@email.com"
        field.layer.borderWidth = 1
        field.textContentType = .emailAddress
        field.keyboardType = .emailAddress
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.clearButtonMode = .whileEditing
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        return field
    }()
    
    private let passwordField: UITextField = {
       let field = UITextField()
        field.tag = 1
        field.placeholder = " Enter the password.."
        field.isSecureTextEntry = true
        field.textContentType = .password
        field.layer.borderWidth = 1
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.textContentType = .password
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
        button.configuration?.title = "Login problems"
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
            alertError(text: "Enter email and password.\nIf You forget password, push Forget Password", mainTitle: "Error login")
            return
        }
        guard let email = emailField.text, !email.isEmpty else {
            alertError(text: "Enter email and password.\nIf You forget your personal data, try again later.", mainTitle: "Error login")
            return
        }
        let internetIsAvailable = InternetConnectionManager.isConnectedToInternet()
        if internetIsAvailable {
            print("Auth with firebase")
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
//                let passwordData = password.data(using: .utf8) ?? Data()
                if let result = result {
                    UserDefaultsManager.shared.userAuthInApp(result: result)
                    UserDefaultsManager.shared.setupForAuth()
                    self?.setupLoadingSpinner()
                    self?.indicatorView.stopAnimating()
                    self?.navigationController?.popToRootViewController(animated: isViewAnimated)
                    print("Internet connection work fine. \nUser successfully authtorized to Firebase")
                } else {
                    self?.alertError(text: error?.localizedDescription ?? "", mainTitle: "Error")
                    self?.clearTextFields()
                }
            }
        } else {
            print("Auth with keychain")
            if let data = KeychainManager.get(service: "Firebase Auth", account: email){
                let pswrd = String(decoding: data, as: UTF8.self)
                if !pswrd.contains(password) {
                    self.alertError(text: "Incorrect password. Try again", mainTitle: "Error!")
                    self.clearTextFields()
                } else {
                    UserDefaultsManager.shared.setupForAuth()
                    UserDefaults.standard.setValue("Set name", forKey: "userName")
                    UserDefaults.standard.setValue(email, forKey: "userMail")
                    setupLoadingSpinner()
                    indicatorView.stopAnimating()
                    navigationController?.popToRootViewController(animated: isViewAnimated)
                }
            } else {
                self.alertError(text: "Can't enter to application")
            }
        }
    }
    
    @objc private func didTapResetPassword(){
        let vc = ResetPasswordViewController()
        navigationController?.pushViewController(vc, animated: isViewAnimated)
    }
    //MARK: - Set up methods
    private func setupView(){
        setupDelegate()
        setupNavigationController()
        setupTargets()
        view.backgroundColor = UIColor(named: "launchBackgroundColor")
        emailField.becomeFirstResponder()
        
    }
    
    private func setupDelegate(){
        passwordField.delegate = self
        emailField.delegate = self
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
        present(nav, animated: isViewAnimated)
    }
    
    private func clearTextFields(){
        emailField.text = ""
        passwordField.text = ""
    }
    
}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard  let field = textField.text, !field.isEmpty else { return false}
        switch textField.tag {
        case 0:
            emailField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        case 1:
            passwordField.resignFirstResponder()
            didTapContinue()
        default:
            break
        }
        return true
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
