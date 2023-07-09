//
//  UserProfileSwitchPasswordVC.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 07.07.2023.
//

import UIKit
import LocalAuthentication
import SnapKit

class UserProfileSwitchPasswordViewController: UIViewController , UITextFieldDelegate{
    
    private var passwordDigits: String = ""
    private var isCheckPassword: Bool
    
    weak var delegate: CheckSuccessSaveProtocol?
    
    init(isCheckPassword: Bool){
        self.isCheckPassword = isCheckPassword
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let passwordLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.text = "Enter code-password"
        label.backgroundColor = .clear
        label.textColor = UIColor(named: "textColor")
        label.font = .systemFont(ofSize: 26, weight: .bold)
        return label
    }()
    
    private let firstTextField :UITextField = {
       let field = UITextField()
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.backgroundColor = UIColor(named: "backgroundColor")
        field.keyboardType = .numberPad
        field.textAlignment = .center
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor(named: "backgroundColor")?.cgColor
        field.layer.cornerRadius = 8
        field.tag = 1
        return field
    }()
    
    private let secondTextField :UITextField = {
       let field = UITextField()
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.backgroundColor = UIColor(named: "backgroundColor")
        field.keyboardType = .numberPad
        field.textAlignment = .center
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor(named: "backgroundColor")?.cgColor
        field.layer.cornerRadius = 8
        field.tag = 2
        return field
    }()
    
    private let thirdTextField :UITextField = {
       let field = UITextField()
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.backgroundColor = UIColor(named: "backgroundColor")
        field.keyboardType = .numberPad
        field.textAlignment = .center
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor(named: "backgroundColor")?.cgColor
        field.layer.cornerRadius = 8
        field.tag = 3
        return field
    }()
    
    private let forthTextField :UITextField = {
       let field = UITextField()
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.backgroundColor = UIColor(named: "backgroundColor")
        field.keyboardType = .numberPad
        field.textAlignment = .center
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor(named: "backgroundColor")?.cgColor
        field.layer.cornerRadius = 8
        field.tag = 4
        return field
    }()
    
    private let confirmPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = true
        button.isEnabled = false
        button.setImage(UIImage(systemName: "lock.open.fill"), for: .normal)
        button.setImage(UIImage(systemName: "lock.fill"), for: .selected)
        button.configuration = .tinted()
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 4
        button.configuration?.title = "Confirm Password"
        button.configuration?.baseBackgroundColor = UIColor(named: "launchBackgroundColor")
        button.configuration?.baseForegroundColor = UIColor(named: "launchBackgroundColor")
        return button
    }()
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        if isCheckPassword {
            confirmPasswordButton.isHidden = true
            addConstrains()
            setupTextField()
            confirmPasswordButton.isHidden = true
            view.backgroundColor = UIColor(named: "navigationControllerColor")
            safetyEnterApplicationWithFaceID()
        } else {
            firstTextField.becomeFirstResponder()
            confirmPasswordButton.isHidden = false
            setupView()
        }
        
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        firstTextField.becomeFirstResponder()
//    }
    
    @objc private func textDidChangeValue(textField: UITextField){
        guard let text = textField.text?.first, text.isNumber else { return }
        if text.utf16.count == 1 {
            switch textField {
            case firstTextField:
                secondTextField.becomeFirstResponder()
                break
            case secondTextField:
                thirdTextField.becomeFirstResponder()
                break
            case thirdTextField:
                forthTextField.becomeFirstResponder()
                break
            case forthTextField:
                forthTextField.resignFirstResponder()
//                safetyEnterApplication(password: passwordDigits)
                break
            default:
                break
            }
        }
    }
    
    @objc private func didTapConfirmPassword(sender: UIButton) {
        if passwordDigits.count == 4 {
            confirmPasswordButton.setImage(UIImage(systemName: "lock.fill"), for: .normal)
            confirmPasswordButton.setTitle("Confirmed", for: .normal)
            authenticateWithFaceID { [weak self] success in
                UserDefaults.standard.setValue(success, forKey: "accessToFaceID")
                UserDefaults.standard.setValue(true, forKey: "isPasswordCodeEnabled")
                let emailUser = UserDefaults.standard.string(forKey: "userMail") ?? "No email"
                try! KeychainManager.save(service: "Local Password", account: emailUser, password: self?.passwordDigits.data(using: .utf8) ?? Data())
                self?.delegate?.isSavedCompletely(boolean: true)
                self?.navigationController?.popToRootViewController(animated: true)
                
            }
        } else {
            alertError(text: "Fill all 4 text fields", mainTitle: "Error!".localized())
        }
        
    }
    //MARK: - Setups for view
    
    private func safetyEnterApplicationWithFaceID(){
        let context = LAContext()
        context.localizedCancelTitle = "Enter Password"
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in to your Account") { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.dismiss(animated: true)
                } else {
                    self?.firstTextField.becomeFirstResponder()
                }
            }
            
        }
    }
    
    private func safetyEnterApplication(password: String){
        let emailUser = UserDefaults.standard.string(forKey: "userMail") ?? "No email"
        guard let data = KeychainManager.get(service: "Local Password", account: emailUser) else { return }
        let passwordKeyChain = String(decoding: data, as: UTF8.self)
        if passwordKeyChain == password {
            self.dismiss(animated: true)
        } else {
            alertError(text: "Incorrect password.\nTry again later", mainTitle: "Error!".localized())
        }
    }
    
    private func setupView(){
        tabBarController?.tabBar.isHidden = true
        setupTextField()
        addConstrains()
        view.backgroundColor = UIColor(named: "navigationControllerColor")
        confirmPasswordButton.addTarget(self, action: #selector(didTapConfirmPassword(sender: )), for: .touchUpInside)
    }
    
    private func setupTextField(){
        
        firstTextField.delegate = self
        secondTextField.delegate = self
        thirdTextField.delegate = self
        forthTextField.delegate = self
        firstTextField.addTarget(self, action: #selector(textDidChangeValue(textField: )), for: UIControl.Event.editingChanged)
        secondTextField.addTarget(self, action: #selector(textDidChangeValue(textField: )), for: UIControl.Event.editingChanged)
        thirdTextField.addTarget(self, action: #selector(textDidChangeValue(textField: )), for: UIControl.Event.editingChanged)
        forthTextField.addTarget(self, action: #selector(textDidChangeValue(textField: )), for: UIControl.Event.editingChanged)
        
    }
    //сделать функции для авторизации перед загрузкой вью
    
    private func authenticateWithFaceID(handler: @escaping (Bool) -> ()) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Face ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async { [weak self] in
                    guard success, error == nil else {
                        handler(success)
                        self?.alertError(text: "Did not get access to Face ID ", mainTitle: "Error!")
                        return
                    }
                    handler(success)
                }
            }
        } else {
            handler(false)
        }
    }
    //MARK: - UITextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let digit = textField.text,
           !digit.isEmpty {
            passwordDigits += digit
        }
        
        if textField.tag == 4 {
            confirmPasswordButton.isEnabled = true
        }
    }
    
    
    
}
//MARK: - snapkit constraints
extension UserProfileSwitchPasswordViewController {
    private func addConstrains(){
        let textFieldSubViews = [firstTextField,secondTextField,thirdTextField,forthTextField]
        let stackView = UIStackView(arrangedSubviews: textFieldSubViews)
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.contentMode = .scaleAspectFit
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(240)
            make.height.equalTo(50)
        }
        
        view.addSubview(passwordLabel)
        passwordLabel.snp.makeConstraints { make in
            make.bottom.equalTo(stackView.snp.top).offset(-50)
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(55)
        }
        
        view.addSubview(confirmPasswordButton)
        confirmPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(50)
            make.leading.trailing.equalToSuperview().inset(80)
            make.height.equalTo(50)
        }
        
        
        
        
    }
}

