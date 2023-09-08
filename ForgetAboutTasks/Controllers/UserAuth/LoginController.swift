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


/// Class for login with current email and password and checking if available service, if email and password are available and correct
class LogInViewController: UIViewController {
    
    //MARK: - UI views
    private let emailField: UITextField = {
       let field = UITextField()
        field.tag = 0
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
        field.leftViewMode = .always
        field.placeholder = "example@email.com"
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
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
        field.leftViewMode = .always
        field.placeholder = "Enter the password..".localized()
        field.isSecureTextEntry = true
        field.textContentType = .password
        field.layer.borderWidth = 1
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
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
        button.configuration?.title = "Continue".localized()
        button.layer.cornerRadius = 8
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        button.configuration?.baseBackgroundColor = UIColor(named: "loginColor")
        return button
    }()
    
    private let resetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = false
        button.configuration = .tinted()
        button.configuration?.title = "Forget password?".localized()
        button.configuration?.baseBackgroundColor = .clear
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        return button
    }()
    
    private let indicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
    }
    //MARK: - Targets
    
    @objc private func didTapChangeVisible(){
        setupHapticMotion(style: .rigid)
        passwordField.isSecureTextEntry.toggle()
        let image = passwordField.isSecureTextEntry ? UIImage(systemName: "eye.fill") :  UIImage(systemName: "eye.slash.fill")
        isPasswordHiddenButton.setImage(image, for: .normal)
    }
    //при входе в аккаунт выгружать также имя фамилию и прочее
    
    @objc private func didTapContinue(){
        setupHapticMotion(style: .soft)
        guard let password = passwordField.text, !password.isEmpty else {
            alertError(text: "Enter email and password.\nIf You forget password, push Forget Password".localized(), mainTitle: "Error login".localized())
            return
        }
        guard let email = emailField.text, !email.isEmpty else {
            alertError(text: "Enter email and password.\nIf You forget your personal data, try again later.".localized(), mainTitle: "Error login".localized())
            return
        }
        checkLoginEntering(email, password)
    }
    
    @objc private func didTapResetPassword(){
        let vc = ResetPasswordViewController()
        navigationController?.pushViewController(vc, animated: isViewAnimated)
    }
    //MARK: - Set up methods
    private func setupView(){
        setupTextFields()
        setupNavigationController()
        setupTargets()
        view.backgroundColor = UIColor(named: "launchBackgroundColor")
    }
    
    private func setupIndicator(){
        view.addSubview(indicator)
        indicator.center = view.center
    }
    
    private func setupTextFields(){
        passwordField.delegate = self
        emailField.delegate = self
        passwordField.rightView = isPasswordHiddenButton
        passwordField.rightViewMode = .whileEditing
    }
    
    private func setupNavigationController(){
        title = "Log In".localized()
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized(), style: .done, target: nil, action: nil)
    }
    
    private func setupTargets(){
        isPasswordHiddenButton.addTarget(self, action: #selector(didTapChangeVisible), for: .touchUpInside)
        configureUserButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        resetPasswordButton.addTarget(self, action: #selector(didTapResetPassword), for: .touchUpInside)
    }
    
    private func clearTextFields(){
        emailField.text = ""
        passwordField.text = ""
        indicator.stopAnimating()
        indicator.isHidden = true
    }
    
    /// Enter function which input textField email and password and check if FirebaseAuthentication has any same email and password
    /// - Parameters:
    ///   - email: textfield text email value
    ///   - password: textfield text password value
    private func checkLoginEntering(_ email: String, _ password: String) {
        let internetIsAvailable = InternetConnectionManager.isConnectedToInternet()
        
        if internetIsAvailable {
            indicator.isHidden = false
            indicator.startAnimating()
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                if let result = result {
                    UserDefaultsManager.shared.saveAccountData(result: result)
                    self?.setupLoadingSpinner()
                    self?.indicator.stopAnimating()
                    self?.navigationController?.popToRootViewController(animated: isViewAnimated)
                    self?.view.window?.rootViewController?.dismiss(animated: isViewAnimated)
                } else {
                    self?.alertError(text: error?.localizedDescription ?? "", mainTitle: "Error")
                    self?.clearTextFields()
                }
            }
        } else {
            
            self.alertError(text: "Can't enter to application during low internet connection".localized())
        }
    }
    
}
//MARK: - Textfield delegate
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = emailField.text,
              let password = passwordField.text else {
            return false
        }
        if !text.isEmpty && !password.isEmpty {
            configureUserButton.isEnabled = true
            return true
        } else {
            configureUserButton.isEnabled = false
            return false
        }
        
    }
}


//MARK: - Constraints extensions
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
