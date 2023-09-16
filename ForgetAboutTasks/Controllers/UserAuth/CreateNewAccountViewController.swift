//
//  CreateNewAccountViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 26.03.2023.
//

import UIKit
import SnapKit
import FirebaseAuth
import AuthenticationServices
//import FirebaseDatabase

///Class for creating account with functionallity to add name
class CreateNewAccountViewController: UIViewController {
    
    //MARK: - UI views
    private let emailField: UITextField = {
       let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
        field.leftViewMode = .always
        field.placeholder = "example@email.com"
        field.layer.borderWidth = 1
        field.textContentType = .emailAddress
        field.textColor = UIColor(named: "textColor")
        field.layer.cornerRadius = 12
        field.textContentType = .emailAddress
        field.autocorrectionType = .no
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.clearButtonMode = .whileEditing
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.enablesReturnKeyAutomatically = true
        field.tag = 0
        return field
    }()
    
    private let passwordField: UITextField = {
       let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
        field.leftViewMode = .always
        field.placeholder = "Enter the password..".localized()
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.layer.borderWidth = 1
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.keyboardType = .default
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.returnKeyType = .continue
        field.enablesReturnKeyAutomatically = true
        field.tag = 1
        return field
    }()
    
    private let secondPasswordField: UITextField = {
         let field = UITextField()
         field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
         field.leftViewMode = .always
         field.placeholder = "Repeat the password..".localized()
         field.isSecureTextEntry = true
         field.textColor = UIColor(named: "textColor")
         field.layer.borderWidth = 1
         field.keyboardType = .default
         field.autocorrectionType = .no
         field.autocapitalizationType = .none
         field.layer.cornerRadius = 12
         field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
         field.returnKeyType = .continue
         field.enablesReturnKeyAutomatically = true
         field.tag = 2
         return field
    }()
    
    private let userNameField: UITextField = {
       let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
        field.leftViewMode = .always
        field.textContentType = .givenName
        field.placeholder = "Enter your name".localized()
        field.textColor = UIColor(named: "textColor")
        field.isSecureTextEntry = false
        field.layer.borderWidth = 1
        field.autocapitalizationType = .words
        field.autocorrectionType = .no
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.returnKeyType = .continue
        field.enablesReturnKeyAutomatically = true
        field.tag = 3
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
    
    private let validationLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor.systemRed
        label.textAlignment = .center
        label.font = .systemFont(ofSize: UIFont.systemFontSize)
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()
    
    private let configureUserButton: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Create new account".localized()
        button.layer.cornerRadius = 8
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        button.configuration?.baseBackgroundColor = UIColor(named: "loginColor")
        button.tintColor = UIColor(named: "textColor")
        button.isEnabled = false
        return button
    }()
    
    private let indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
    }
    //MARK: - Targets
    @objc private func didTapChangeVisible(){
        setupHapticMotion(style: .rigid)
        let fields = [passwordField, secondPasswordField]
        fields.forEach { field in
            field.isSecureTextEntry.toggle()
        }
        let image = fields.first!.isSecureTextEntry ? UIImage(systemName: "eye.fill") : UIImage(systemName: "eye.slash.fill")
        isPasswordHiddenButton.setImage(image, for: .normal)
    }
    
    @objc private func didTapCreateNewAccount(){
        setupHapticMotion(style: .soft)
        indicator.startAnimating()
        view.alpha = 0.6
        
        guard let mailField = emailField.text, !mailField.isEmpty,
              let firstPassword = passwordField.text, !firstPassword.isEmpty,
              let secondPassword = secondPasswordField.text, !secondPassword.isEmpty,
              let userName = userNameField.text, !userName.isEmpty else {
            alertError(text: "Enter text in all fields".localized())
            indicator.stopAnimating()
            view.alpha = 1
            return
        }
        createNewUserAccount(firstPassword, secondPassword, mailField, userName)
    }

    @objc private func didTapGenerateStrongPassword(sender: UIBarButtonItem){
        let alertController = UIAlertController(title: "Warning!".localized() , message: "Do you want to use strong generated password for your account?".localized(), preferredStyle: .actionSheet)
        let confirmButton = UIAlertAction(title: "Create".localized(), style: .default,handler: { [weak self] _ in
            self?.didTapChangeVisible()
            let password = self?.generateStrongPassword()
            let passwordFields = [self?.passwordField, self?.secondPasswordField]
            passwordFields.forEach { field in
                field?.text = ""
                field?.text = password
                field?.resignFirstResponder()
                
            }
        })
        alertController.addAction(confirmButton)
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alertController, animated: isViewAnimated)
    }
    
    @objc private func didTapDismissTextField(_ textField: UITextField){
        textField.resignFirstResponder()
    }
    //MARK: - Set up methods
    private func setupView(){
        setupConstraints()
        setupNavigationController()
        setupTargets()
        setupIndicator()
        setupTextFields()
        view.backgroundColor = UIColor(named: "launchBackgroundColor")
    }
    
    private func setupIndicator(){
        view.addSubview(indicator)
        indicator.center = view.center
    }
    
    private func setupNavigationController(){
        title = "Create New Account".localized()
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
    }
    
    private func setupTextFields(){
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50 ))
        toolBar.barStyle = .default
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 1.0
        let action = UIBarButtonItem(title: "Generate strong password".localized(), style: .done, target: self, action: #selector(didTapGenerateStrongPassword))
        let doneButton = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action: #selector(didTapDismissTextField))
        action.tintColor = UIColor(named: "textColor")
        toolBar.setItems([space, fixedSpace, action , fixedSpace, doneButton], animated: isViewAnimated)
        toolBar.backgroundColor = .systemGray3
        toolBar.sizeToFit()
        
        let fields = [passwordField,secondPasswordField]
        fields.forEach { field in
            field.inputAccessoryView = toolBar as UIView
            field.rightView = isPasswordHiddenButton
            field.rightViewMode = .whileEditing
            field.delegate = self
            field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        emailField.delegate = self
        userNameField.delegate = self
    
    }
    
    private func setupTargets(){
        isPasswordHiddenButton.addTarget(self, action: #selector(didTapChangeVisible), for: .touchUpInside)
        configureUserButton.addTarget(self, action: #selector(didTapCreateNewAccount), for: .touchUpInside)
    }
    
    private func clearAllFields(){
        let fields = [emailField, passwordField, secondPasswordField, userNameField]
        fields.forEach { textField in
            textField.text = ""
            validationLabel.text = ""
            configureUserButton.isEnabled = false
        }
    }
    
    /// Function for checking if Firebase service is enable and if enable ask for method
    /// - Parameters:
    ///   - firstPassword: first password text from textField
    ///   - secondPassword: repeat password text from second TextField
    ///   - mailField: mail text from email TextField
    ///   - userName: user name text from userName TextField
    private func createNewUserAccount(_ firstPassword: String, _ secondPassword: String, _ mailField: String, _ userName: String) {
        if firstPassword.elementsEqual(secondPassword) {
            if secondPassword.count >= 8 {
                FirebaseAuth.Auth.auth().createUser(withEmail: mailField, password: secondPassword) { [weak self] _, error in
                    guard error == nil else {
                        self?.alertError(text: "This account has already been created".localized())
                        self?.indicator.stopAnimating()
                        self!.view.alpha = 1
                        self?.clearAllFields()
                        return
                    }
                    self?.askForSavingPassword(email: mailField, password: firstPassword,userName: userName)
                }
            } else {
                alertError(text: "Password must contains at least 8 symbols, have uppercase and some numbers".localized(), mainTitle: "Warning".localized())
                passwordField.text = ""
                secondPasswordField.text = ""
            }
            
        } else {
            alertError(text: "Passwords must be identical".localized(), mainTitle: "Warning".localized())
        }
    }
    
    /// function with getting inputs email,password and userName
    /// - Parameters:
    ///   - email: email text from textfield
    ///   - password: password text from textfield
    ///   - userName: username text from textfield
    private func askForSavingPassword(email: String, password: String,userName: String){
        view.alpha = 1
        createNewAccount(email: email, userName: userName)
        indicator.stopAnimating()
    }
    
    
    /// function for saving data to user defaults and some animations works
    /// - Parameters:
    ///   - email: email text from textfield
    ///   - userName: user name text from textfield
    private func createNewAccount(email: String, userName: String) {
        UserDefaults.standard.setValue(userName, forKey: "userName")
        UserDefaults.standard.setValue(email, forKey: "userMail")
        UserDefaults.standard.setValue(false, forKey: "authWithGoogle")
        DispatchQueue.main.async { [weak self] in
            self?.view.alpha = 1.0
            self?.indicator.stopAnimating()
            self?.navigationController?.popToRootViewController(animated: isViewAnimated)
            self?.view.window?.rootViewController?.dismiss(animated: isViewAnimated)
            dump(UserDefaults.standard.string(forKey: "userName"))
            dump(UserDefaults.standard.string(forKey: "userMail"))
        }
    }
    
    
    
    
    /// Function for generation random password text with custom
    /// - Returns: return password string value
    private func generateStrongPassword() -> String{
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+?"
        var password = ""
        
        for _ in 0..<16 {
            let randomIndex = Int.random(in: 0..<chars.count)
            let randomChar = chars[chars.index(chars.startIndex, offsetBy: randomIndex)]
            password.append(randomChar)
        }
        return password
    }
}

//MARK: - Delegate extensions
extension CreateNewAccountViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard  let field = textField.text, !field.isEmpty else { return false}
        guard let firstText = passwordField.text, let secondText = secondPasswordField.text else { return false }
        switch textField.tag {
        case 0:
            emailField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        case 1:
            passwordField.resignFirstResponder()
            secondPasswordField.becomeFirstResponder()
        case 2:
            secondPasswordField.resignFirstResponder()
            userNameField.becomeFirstResponder()
        case 3:
            userNameField.resignFirstResponder()
            if firstText.passValidation() && secondText.passValidation(),
               passwordField.text == secondPasswordField.text {
                configureUserButton.isEnabled = true
                didTapCreateNewAccount()
            }
        default:
            break
        }
        return true
    }
    
    override func textFieldDidChange(_ textField: UITextField) {
        if !passwordField.text!.isEmpty && !secondPasswordField.text!.isEmpty && !emailField.text!.isEmpty {
            configureUserButton.isEnabled = true
        } else {
            configureUserButton.isEnabled = false
        }
    }
}
//MARK: - Extensions
extension CreateNewAccountViewController {
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
        
        view.addSubview(validationLabel)
        validationLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        view.addSubview(configureUserButton)
        configureUserButton.snp.makeConstraints { make in
            make.top.equalTo(validationLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(60)
            make.height.equalTo(40)
        }
        
        
    }
}
