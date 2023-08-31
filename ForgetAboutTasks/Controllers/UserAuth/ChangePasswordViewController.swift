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
        field.isSecureTextEntry = true
        field.layer.borderWidth = 1
        field.textContentType = .password
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.returnKeyType = .continue
        field.tag = 0
        return field
    }()
    
    private let firstNewPasswordTextField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
        field.leftViewMode = .always
        field.placeholder = "Enter new password".localized()
        field.textColor = UIColor(named: "textColor")
        field.isSecureTextEntry = true
        field.layer.borderWidth = 1
        field.textContentType = .password
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.returnKeyType = .continue
        field.tag = 1
        return field
    }()
    
    private let secondNewPasswordTextField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
        field.leftViewMode = .always
        field.placeholder = "Repeat the password".localized()
        field.textColor = UIColor(named: "textColor")
        field.isSecureTextEntry = true
        field.layer.borderWidth = 1
        field.textContentType = .password
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 16
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        field.returnKeyType = .continue
        field.tag = 2
        return field
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
    @objc private func didTapConfirmChangePassword(sender: UIButton){
        indicator.startAnimating()
        view.alpha = 0.8
        checkPasswordFields()
    }
    
    @objc private func didTapChangeVisible(){
        setupHapticMotion(style: .rigid)
        if isPasswordHidden {
            oldPasswordField.isSecureTextEntry = false
            firstNewPasswordTextField.isSecureTextEntry = false
            secondNewPasswordTextField.isSecureTextEntry = false
            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        } else {
            oldPasswordField.isSecureTextEntry = true
            firstNewPasswordTextField.isSecureTextEntry = true
            secondNewPasswordTextField.isSecureTextEntry = true
            isPasswordHiddenButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        }
        isPasswordHidden = !isPasswordHidden
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
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50 ))
        toolBar.barStyle = .default
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 1.0
        let action = UIBarButtonItem(title: "Generate strong password".localized(), style: .done, target: self, action: #selector(didTapGenerateStrongPassword))
        action.tintColor = UIColor(named: "textColor")
        toolBar.items = [space, fixedSpace, action , fixedSpace, space]
        toolBar.backgroundColor = .systemGray3
        toolBar.sizeToFit()
        
        oldPasswordField.delegate = self
        oldPasswordField.rightView = isPasswordHiddenButton
        oldPasswordField.rightViewMode = .always
        
        firstNewPasswordTextField.rightView = isPasswordHiddenButton
        firstNewPasswordTextField.delegate = self
        firstNewPasswordTextField.rightViewMode = .whileEditing
        
        secondNewPasswordTextField.delegate = self
        secondNewPasswordTextField.rightView = isPasswordHiddenButton
        secondNewPasswordTextField.rightViewMode = .whileEditing

        firstNewPasswordTextField.inputAccessoryView = toolBar as UIView
        secondNewPasswordTextField.inputAccessoryView = toolBar as UIView
    }
    
    private func setupIndicator(){
        view.addSubview(indicator)
        indicator.center = view.center
    }
    
    
    private func checkPasswordFields(){
        guard let oldPassword = oldPasswordField.text else { alertError(text: "Enter correct old password".localized()); return }
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
        
        view.addSubview(confirmNewPasswordButton)
        confirmNewPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(secondNewPasswordTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        
    }
}
