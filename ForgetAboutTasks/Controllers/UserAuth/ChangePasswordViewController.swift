//
//  ChangePasswordController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 22.08.2023.
//

import UIKit
import Firebase


class ChangePasswordViewController: UIViewController {
    
    private let accountMail: String
    
    private var isPasswordHidden: Bool = true
    
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
        confirmNewPasswordButton.isEnabled = true
        indicator.startAnimating()
        view.alpha = 0.8
        checkPasswordFields()
    }
    @objc private func didTapChangeVisible(){
        setupHapticMotion(style: .rigid)
        let fields = [oldPasswordField,firstNewPasswordTextField,secondNewPasswordTextField]
        fields.forEach { field in
            field.isSecureTextEntry = !field.isSecureTextEntry
        }
//        if isPasswordHidden {
//            firstNewPasswordTextField.isSecureTextEntry = false
//            secondNewPasswordTextField.isSecureTextEntry = false
//            oldPasswordField.isSecureTextEntry = false
//            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
//        } else {
//            firstNewPasswordTextField.isSecureTextEntry = true
//            secondNewPasswordTextField.isSecureTextEntry = true
//            oldPasswordField.isSecureTextEntry = true
//            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
//        }
//        isPasswordHidden = !isPasswordHidden
        
        
        
//        if isPasswordHidden {
//            oldPasswordField.isSecureTextEntry = false
//            firstNewPasswordTextField.isSecureTextEntry = false
//            secondNewPasswordTextField.isSecureTextEntry = false
//            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
//        } else {
//            oldPasswordField.isSecureTextEntry = true
//            firstNewPasswordTextField.isSecureTextEntry = true
//            secondNewPasswordTextField.isSecureTextEntry = true
//            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
//        }
//        isPasswordHidden = !isPasswordHidden
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
        }

        oldPasswordField.inputAccessoryView = toolBarOldPassword as UIView
        firstNewPasswordTextField.inputAccessoryView = toolBarNewPassword as UIView
        secondNewPasswordTextField.inputAccessoryView = toolBarNewPassword as UIView
        confirmNewPasswordButton.isEnabled = false
    }
    
    private func setupIndicator(){
        view.addSubview(indicator)
        indicator.center = view.center
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
    private func checkPasswordFields(){
        guard let oldPassword = oldPasswordField.text else { alertError(text: "Enter correct old password".localized()); return }
        let authCredential = EmailAuthProvider.credential(withEmail: accountMail, password: oldPassword)
        if let password = firstNewPasswordTextField.text, !password.isEmpty,
           let secondPassword = secondNewPasswordTextField.text, !secondPassword.isEmpty,
           password == secondPassword {
            Auth.auth().currentUser?.reauthenticate(with: authCredential, completion: { [weak self] _, error in
                if let error = error{
                    self?.alertError(text: error.localizedDescription)
                    self?.indicator.stopAnimating()
                } else {
                    Auth.auth().currentUser?.updatePassword(to: password, completion: { error in
                        if let error = error {
                            self?.alertError(text: error.localizedDescription)
                            self?.indicator.stopAnimating()
                        } else {
                            self?.indicator.stopAnimating()
                            self?.navigationController?.popToRootViewController(animated: isViewAnimated)
//                            DispatchQueue.main.async {
//                                if let nav = self?.navigationController {
//                                    nav.popViewController(animated: true)
//                                }
//                            }
                        }
                    })
                }
            })
        } else {
            alertError(text: "Password is not equal or valid. Try again".localized())
            indicator.stopAnimating()
        }
        view.alpha = 1
    }
    
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
    
    private func clearTextFields(){
        firstNewPasswordTextField.text = ""
        secondNewPasswordTextField.text = ""
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
                alertError(text: "Password is not valid")
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
        }
    }
//    #error("Добавить сюда же валидацию паролей, как в RegisterAccountController и также лейбл для отображения")
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == firstNewPasswordTextField || textField == secondNewPasswordTextField {
            validationLabel.isHidden = false
        } else {
            validationLabel.isHidden = true
        }
        
        
        
//        let firstField = textField.viewWithTag(1)
//        let secondField = textField.viewWithTag(2)
//
//        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
//        let secondText = (secondField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        if newText.passValidation() {
            validationLabel.text = "Password is valid"
            validationLabel.textColor = .systemGreen
            confirmNewPasswordButton.isEnabled = false
        } else {
            validationLabel.text = "The password must contain at least one capital letter, a number and must be at least 8 characters long"
            validationLabel.textColor = .systemRed
            confirmNewPasswordButton.isEnabled = false
        }
//        if text == secondText {
//            validationLabel.text = "Passwords are equal"
//            validationLabel.textColor = .systemGreen
//        } else {
//            validationLabel.text = "Passwords are not equal"
//            validationLabel.textColor = .systemRed
//        }
//        if newText.passValidation() {
//            validationLabel.text = "Password is valid"
//            validationLabel.textColor = .systemGreen
//            if firstNewPasswordTextField.text == secondNewPasswordTextField.text {
//                confirmNewPasswordButton.isEnabled = true
//                validationLabel.text = "Password is valid"
//                validationLabel.textColor = .systemGreen
//            } else {
//                validationLabel.text = "Passwords are not equal. Try again"
//                validationLabel.textColor = .systemRed
//                confirmNewPasswordButton.isEnabled = false
//            }
//        } else {
//            validationLabel.text = "The password must contain at least one capital letter, a number and must be at least 8 characters long"
//            validationLabel.textColor = .systemRed
//        }
        
//        if text.passValidation() && secondText.passValidation() {
//            validationLabel.text = "Password is valid"
//            validationLabel.textColor = .systemGreen
//            if firstNewPasswordTextField.text == secondNewPasswordTextField.text {
//                confirmNewPasswordButton.isEnabled = true
//                validationLabel.text = "Password is valid"
//                validationLabel.textColor = .systemGreen
//            } else {
//                validationLabel.text = "Passwords are not equal. Try again"
//                validationLabel.textColor = .systemRed
//                confirmNewPasswordButton.isEnabled = false
//            }
//        } else {
//            validationLabel.text = "The password must contain at least one capital letter, a number and must be at least 8 characters long"
//            validationLabel.textColor = .systemRed
//        }
        return true
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
