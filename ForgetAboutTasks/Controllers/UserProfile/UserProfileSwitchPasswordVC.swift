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
    private var confirmPasswordDigits: String = ""
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
        label.text = "Enter code-password".localized()
        label.backgroundColor = .clear
        label.textColor = UIColor(named: "textColor")
        label.font = .systemFont(ofSize: 26, weight: .bold)
        return label
    }()
    
    private let firstTextField :UITextField = {
        let field = UITextField()
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor(named: "textColor")?.cgColor
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.backgroundColor = UIColor(named: "backgroundColor")
        field.keyboardType = .numberPad
        field.textAlignment = .center
        field.layer.cornerRadius = 8
        field.tag = 1
        return field
    }()
    
    private let secondTextField :UITextField = {
        let field = UITextField()
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor(named: "textColor")?.cgColor
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.backgroundColor = UIColor(named: "backgroundColor")
        field.keyboardType = .numberPad
        field.textAlignment = .center
        field.layer.cornerRadius = 8
        field.tag = 2
        return field
    }()
    
    private let thirdTextField :UITextField = {
        let field = UITextField()
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor(named: "textColor")?.cgColor
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.backgroundColor = UIColor(named: "backgroundColor")
        field.keyboardType = .numberPad
        field.textAlignment = .center
        field.layer.cornerRadius = 8
        field.tag = 3
        return field
    }()
    
    private let forthTextField :UITextField = {
        let field = UITextField()
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor(named: "textColor")?.cgColor
        field.isSecureTextEntry = true
        field.textColor = UIColor(named: "textColor")
        field.backgroundColor = UIColor(named: "backgroundColor")
        field.keyboardType = .numberPad
        field.textAlignment = .center
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
        button.configuration?.title = "Confirm Password".localized()
        button.configuration?.baseBackgroundColor = UIColor(named: "launchBackgroundColor")
        button.configuration?.baseForegroundColor = UIColor(named: "launchBackgroundColor")
        return button
    }()
    
    private let faceIdButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .thin)
        button.isHidden = true
        button.setImage(UIImage(systemName: "faceid")?.withRenderingMode(.alwaysTemplate).withConfiguration(config), for: .normal)
        button.tintColor = UIColor(named: "textColor")
        button.backgroundColor = .clear
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        return button
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        if isCheckPassword {
            setupEntryView()
        } else {
            setupView()
        }
        
    }
    
    //MARK: - Target Methods
    
    /// Function for checking when current view is open and for segue to next field
    /// - Parameter textField: input textfield by row
    @objc private func textDidChangeValue(textField: UITextField){
        guard let text = textField.text?.first, text.isNumber else { return }
        if text.utf16.count == 1 {
            //for first input when user create password
            if passwordDigits.count != 4 && !isCheckPassword {
                switch textField {
                case firstTextField:
                    passwordDigits += firstTextField.text!
                    secondTextField.becomeFirstResponder()
                    break
                case secondTextField:
                    passwordDigits += secondTextField.text!
                    thirdTextField.becomeFirstResponder()
                    break
                case thirdTextField:
                    passwordDigits += thirdTextField.text!
                    forthTextField.becomeFirstResponder()
                    break
                case forthTextField:
                    passwordDigits += forthTextField.text!
                    forthTextField.resignFirstResponder()
                    secondPasswordConfirm()
                    break
                default:
                    break
                }
                //for second repeat password when user create password
            } else if passwordDigits.count == 4 {
                switch textField {
                    
                case firstTextField:
                    confirmPasswordDigits += firstTextField.text!
                    secondTextField.becomeFirstResponder()
                    break
                case secondTextField:
                    confirmPasswordDigits += secondTextField.text!
                    thirdTextField.becomeFirstResponder()
                    break
                case thirdTextField:
                    confirmPasswordDigits += thirdTextField.text!
                    forthTextField.becomeFirstResponder()
                    break
                case forthTextField:
                    confirmPasswordDigits += forthTextField.text!
                    forthTextField.resignFirstResponder()
                    confirmPasswordButton.isEnabled = true
                    confirmPasswordButton.configuration?.baseBackgroundColor = .systemBlue
                    confirmPasswordButton.configuration?.baseForegroundColor = UIColor(named: "textColor")
                    break
                default:
                    break
                }
                //for checking password if user launch the app
            } else if isCheckPassword && passwordDigits.count != 4 {
                switch textField {
                case firstTextField:
                    passwordDigits += firstTextField.text!
                    secondTextField.becomeFirstResponder()
                    break
                case secondTextField:
                    passwordDigits += secondTextField.text!
                    thirdTextField.becomeFirstResponder()
                    break
                case thirdTextField:
                    passwordDigits += thirdTextField.text!
                    forthTextField.becomeFirstResponder()
                    break
                case forthTextField:
                    passwordDigits += forthTextField.text!
                    forthTextField.resignFirstResponder()
                    checkCorrectPassword(textField: textField)
                    break
                default:
                    break
                }
            }
        }
    }
    
    
    /// Function for saving password when user create or change password value. Password store in Keychain, other value saved in UserDefaults
    /// - Parameter sender: button sender (for necessary using)
    @objc private func didTapConfirmPassword(sender: UIButton) {
        setupHapticMotion(style: .light)
        let emailUser = UserDefaults.standard.string(forKey: "userMail") ?? "No email"
        let password = confirmPasswordDigits
        if passwordDigits.count == 4 && passwordDigits == confirmPasswordDigits {
            confirmPasswordButton.setImage(UIImage(systemName: "lock.fill"), for: .normal)
            confirmPasswordButton.setTitle("Confirmed".localized(), for: .normal)
            checkAuthForFaceID { [weak self] success in
                UserDefaults.standard.setValue(success, forKey: "accessToFaceID")
                UserDefaults.standard.setValue(true, forKey: "isPasswordCodeEnabled")
                UserDefaults.standard.setValue(true, forKey: "isUserConfirmPassword")
                try! KeychainManager.shared.savePassword(password: password, email: emailUser)
                self?.delegate?.isSavedCompletely(boolean: true)
                self?.navigationController?.popViewController(animated: isViewAnimated)
                self?.dismiss(animated: isViewAnimated)
            }
        } else {
            alertError(text: "You entered different passwords. Try again".localized())
            clearRequest()
        }
    }
    @objc private func didTapActiveFaceID(){
        setupHapticMotion(style: .medium)
        safetyEnterApplicationWithFaceID(textField: firstTextField)
    }
    
    //MARK: - Setups for view
    
    /// This setup using for creating or changing password value
    private func setupView(){
        view.backgroundColor = .systemBackground
        confirmPasswordButton.addTarget(self, action: #selector(didTapConfirmPassword(sender: )), for: .touchUpInside)
        setupRegistrationView()
        setupTextField()
        addConstrains()
    }
    
    private func setupRegistrationView(){
        setupHapticMotion(style: .light)
        firstTextField.becomeFirstResponder()
        confirmPasswordButton.isHidden = false
        tabBarController?.tabBar.isHidden = true
    }
    ///This setup function using for entry setups when app is launching
    private func setupEntryView(){
        
        title = "Before using".localized()
        view.backgroundColor = UIColor(named: "calendarHeaderColor")
        tabBarController?.tabBar.isHidden = true
        confirmPasswordButton.isHidden = true
        let accessFaceID = UserDefaults.standard.bool(forKey: "accessToFaceID")
        if accessFaceID {
            faceIdButton.isHidden = false
            faceIdButton.addTarget(self, action: #selector(didTapActiveFaceID), for: .touchUpInside)
        } else {
            faceIdButton.isHidden = true
        }
        addConstrains()
        setupTextField()
        safetyEnterApplicationWithFaceID(textField: firstTextField)
    }
    
    private func setupTextField(){
        let textFields = [firstTextField, secondTextField, thirdTextField, forthTextField]
        textFields.forEach { textField in
            textField.addTarget(self, action: #selector(textDidChangeValue(textField: )), for: UIControl.Event.editingChanged)
        }
    }
    
    /// Function for checking password when app is first launched
    /// - Parameter textField: input textField check when its tag equal to 4
    private func checkCorrectPassword(textField: UITextField){
        let emailUser = UserDefaults.standard.string(forKey: "userMail") ?? "No email"
        let textValue = try! KeychainManager.shared.getPassword(email: emailUser)
        if textField.tag == 4 {
            if textValue.contains(passwordDigits){
                UserDefaults.standard.setValue(true, forKey: "isUserConfirmPassword")
                showAlertForUser(text: "Success".localized(), duration: .now()+1, controllerView: view)
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.navigationController?.popViewController(animated: isViewAnimated)
                    self.dismiss(animated: isViewAnimated)
                }
            } else {
                alertError(text: "Incorrect password.\nPlease try again!".localized())
                clearRequest()
            }
        }
    }
    
    private func clearRequest(){
        firstTextField.text = ""
        secondTextField.text = ""
        thirdTextField.text = ""
        forthTextField.text = ""
        passwordDigits = ""
        confirmPasswordDigits = ""
        firstTextField.becomeFirstResponder()
        confirmPasswordButton.isEnabled = false
        passwordLabel.text = "Enter code-password".localized()
    }
    
    private func secondPasswordConfirm(){
        firstTextField.text = ""
        secondTextField.text = ""
        thirdTextField.text = ""
        forthTextField.text = ""
        firstTextField.becomeFirstResponder()
        passwordLabel.text = "Confirm password".localized()
    }
}
//MARK: - Setup constraints
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
        
        view.addSubview(faceIdButton)
        faceIdButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(view.frame.size.width/4)
        }
        
        
        
    }
}

