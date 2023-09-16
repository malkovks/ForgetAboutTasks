//
//  ChangePasswordController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 22.08.2023.
//

import UIKit
import Firebase

///class for changing password of created Firebase account
class ChangePasswordViewController: UIViewController {
    
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
        label.text = "Set new password".localized()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let oldPasswordField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
        field.leftViewMode = .always
        field.placeholder = "Enter old password".localized()
        field.textColor = UIColor(named: "textColor")
        field.isSecureTextEntry = false
        field.layer.borderWidth = 1
        field.textContentType = .none
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.returnKeyType = .continue
        field.keyboardType = .asciiCapable
        field.tag = 0
        return field
    }()
    
    private let firstNewPasswordTextField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
        field.leftViewMode = .always
        field.placeholder = "Enter new password".localized()
        field.textColor = UIColor(named: "textColor")
        field.isSecureTextEntry = false
        field.layer.borderWidth = 1
        field.textContentType = .none
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.returnKeyType = .continue
        field.keyboardType = .asciiCapable
        field.tag = 1
        return field
    }()
    
    private let secondNewPasswordTextField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
        field.leftViewMode = .always
        field.placeholder = "Repeat the password".localized()
        field.textColor = UIColor(named: "textColor")
        field.isSecureTextEntry = false
        field.layer.borderWidth = 1
        field.textContentType = .none
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 16
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.returnKeyType = .continue
        field.keyboardType = .asciiCapable
        field.tag = 2
        return field
    }()
    
    private let validationLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.text = "Password validation"
        label.font = .systemFont(ofSize: UIFont.systemFontSize)
        label.textColor = .systemRed
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()
    
    private let confirmNewPasswordButton: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Reset".localized()
        button.layer.cornerRadius = 8
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        button.configuration?.baseBackgroundColor = UIColor(named: "loginColor")
        return button
    }()
    
    private let isPasswordHiddenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        button.tintColor = UIColor(named: "navigationControllerColor")
        button.backgroundColor = UIColor(named: "launchBackgroundColor")
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let indicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        oldPasswordField.becomeFirstResponder()
    }
    
    //MARK: - Target methods
    @objc private func didTapConfirmChangePassword(){
        indicator.startAnimating()
        view.alpha = 0.6
        checkPasswordFields()
    }
    @objc private func didTapChangeVisible(){
        setupHapticMotion(style: .rigid)
        let fields = [oldPasswordField, firstNewPasswordTextField, secondNewPasswordTextField]
        fields.forEach { field in
            field.isSecureTextEntry.toggle()
        }
        let image = oldPasswordField.isSecureTextEntry ? UIImage(systemName: "eye.fill") : UIImage(systemName: "eye.slash.fill")
        isPasswordHiddenButton.setImage(image, for: .normal)
    }
    
    @objc private func didTapGenerateStrongPassword(sender: UIBarButtonItem){
        let alertController = UIAlertController(title: "Warning!".localized() , message: "Do you want to use strong generated password for your account?".localized(), preferredStyle: .actionSheet)
        let confirmButton = UIAlertAction(title: "Create".localized(), style: .default,handler: { [weak self] _ in
            let password = self?.generateStrongPassword()
            let passwordFields = [self?.firstNewPasswordTextField, self?.secondNewPasswordTextField]
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
    
    @objc private func didTapDismissKeyboard(){
        let fields = [oldPasswordField, firstNewPasswordTextField, secondNewPasswordTextField]
        fields.forEach { field in
            field.resignFirstResponder()
        }
    }
    //MARK: - Setup methods
    private func setupView(){
        setupNavigationController()
        setupTextFields()
        setupConstraints()
        setupIndicator()
        tabBarController?.tabBar.isHidden = true
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
        let toolBarNewPassword = setupCustomToolBar(newPassword: true)
        let toolBarOldPassword = setupCustomToolBar(newPassword: false)
        
        let fields = [oldPasswordField, firstNewPasswordTextField, secondNewPasswordTextField]
        fields.forEach { field in
            field.delegate = self
            field.rightView = isPasswordHiddenButton
            field.rightViewMode = .whileEditing
            field.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingChanged)
        }
        
        
        isPasswordHiddenButton.addTarget(self, action: #selector(didTapChangeVisible), for: .touchUpInside)
        
        oldPasswordField.inputAccessoryView = toolBarOldPassword as UIView
        firstNewPasswordTextField.inputAccessoryView = toolBarNewPassword as UIView
        secondNewPasswordTextField.inputAccessoryView = toolBarNewPassword as UIView
        confirmNewPasswordButton.isEnabled = false
    }
    
    private func setupIndicator(){
        view.addSubview(indicator)
        indicator.center = view.center
    }
    
    private func clearTextFields(){
        firstNewPasswordTextField.text = ""
        secondNewPasswordTextField.text = ""
    }
    
    private func setupCustomToolBar(newPassword boolean: Bool) -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50 ))
        toolBar.barStyle = .black
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 1.0
        let action = UIBarButtonItem(title: "Generate strong password".localized(), style: .done, target: self, action: #selector(didTapGenerateStrongPassword))
        action.tintColor = UIColor(named: "textColor")
        
        toolBar.backgroundColor = .systemGray3
        toolBar.sizeToFit()
        let closeButton = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action: #selector(didTapDismissKeyboard))
        closeButton.tintColor = UIColor(named: "textColor")
        if boolean {
            toolBar.items = [space, fixedSpace, action , fixedSpace, closeButton]
        } else {
            toolBar.items = [space,closeButton]
        }
        return toolBar
    }
    
    //MARK: - Business logic methods
    
    /// Function check if auth current user is enable and can get access to firebase server to request update password
    private func checkPasswordFields(){
        guard let oldPassword = oldPasswordField.text else { alertError(text: "Enter correct old password".localized()); return }
        let authCredential = EmailAuthProvider.credential(withEmail: accountMail, password: oldPassword)
        if let password = firstNewPasswordTextField.text,
           let secondPassword = secondNewPasswordTextField.text,
           password == secondPassword,
           password.passValidation() && secondPassword.passValidation() {
            Auth.auth().currentUser?.reauthenticate(with: authCredential, completion: { [weak self] _, error in
                if let error = error{
                    self?.alertError(text: error.localizedDescription)
                    self?.indicator.stopAnimating()
                    self!.view.alpha = 1
                } else {
                    Auth.auth().currentUser?.updatePassword(to: password, completion: { error in
                        if let error = error {
                            self?.alertError(text: error.localizedDescription)
                            self?.indicator.stopAnimating()
                            self!.view.alpha = 1
                        } else {
                            self?.indicator.stopAnimating()
                            self!.view.alpha = 1
                            self?.showAlertForUser(text: "Password was successfully changed", duration: .now()+1, controllerView: self!.view)
                            self?.navigationController?.popToRootViewController(animated: isViewAnimated)
                            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                                self?.navigationController?.popToRootViewController(animated: isViewAnimated)
                            }
                        }
                    })
                }
            })
        } else {
            alertError(text: "Password is not equal or valid. Try again".localized())
            indicator.stopAnimating()
            view.alpha = 1
        }
    }
    
    
    /// Generate random 16 elements password with using random
    /// - Returns: return created password
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
//MARK: - Delegates and constraints
extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == oldPasswordField {
            oldPasswordField.resignFirstResponder()
            firstNewPasswordTextField.becomeFirstResponder()
            return true
        } else if textField == firstNewPasswordTextField {
            firstNewPasswordTextField.resignFirstResponder()
            secondNewPasswordTextField.becomeFirstResponder()
            return true
        } else if textField == secondNewPasswordTextField {
            if let text = firstNewPasswordTextField.text, text.passValidation(), firstNewPasswordTextField.text == secondNewPasswordTextField.text {
                textField.resignFirstResponder()
                didTapConfirmChangePassword()
                return true
            } else {
                alertError(text: "Password is not valid".localized())
                clearTextFields()
                return false
            }
        } else {
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let firstText = firstNewPasswordTextField.text, let secondText = secondNewPasswordTextField.text else { return }
        if !firstText.isEmpty && !secondText.isEmpty {
            confirmNewPasswordButton.isEnabled = true
        } else {
            confirmNewPasswordButton.isEnabled = false
        }
    }
}

extension ChangePasswordViewController {
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
        
        view.addSubview(validationLabel)
        validationLabel.snp.makeConstraints { make in
            make.top.equalTo(secondNewPasswordTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        view.addSubview(confirmNewPasswordButton)
        confirmNewPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(validationLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        
    }
}
