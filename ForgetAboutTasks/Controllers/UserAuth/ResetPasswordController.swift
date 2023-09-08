//
//  ResetPasswordController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 30.05.2023.
//

import UIKit
import SnapKit
import FirebaseAuth


///class for reset password if user forgot password
class ResetPasswordViewController: UIViewController{
    
    private var isPasswordHidden: Bool = true
    
    //MARK: - UI views
    private let emailTextField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.size.height))
        field.leftViewMode = .always
        field.placeholder = "Enter your email".localized()
        field.isSecureTextEntry = false
        field.layer.borderWidth = 1
        field.returnKeyType = .continue
        field.autocorrectionType = .no
        field.keyboardType = .emailAddress
        field.textContentType = .emailAddress
        field.autocapitalizationType = .none
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        return field
    }()
    
    private let resetPasswordButton: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Reset password".localized()
        button.layer.cornerRadius = 8
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        button.configuration?.baseBackgroundColor = UIColor(named: "loginColor")
        return button
    }()
    
    private let indicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    //MARK: - Targets
    
    
    @objc private func didTapResetPassword(){
        setupHapticMotion(style: .medium)
        guard let text = emailTextField.text, !text.isEmpty else {
            alertError(text: "Enter your email".localized())
            return
        }
        view.alpha = 0.8
        indicatorView.startAnimating()
        
        requestForReset(text)
    }
    
    //MARK: - Set up methods
    private func setupView(){
        setupTextField()
        setupConstraints()
        setupNavigationController()
        setupTargets()
        setupActivityView()
        emailTextField.resignFirstResponder()
        view.backgroundColor = UIColor(named: "launchBackgroundColor")
    }
    
    private func setupActivityView(){
        view.addSubview(indicatorView)
        indicatorView.center = view.center
    }
    
    private func setupTextField(){
        emailTextField.delegate = self
        emailTextField.becomeFirstResponder()
    }
    
    private func setupNavigationController(){
        title = "Password recovery".localized()
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
    }
    
    private func setupTargets(){
        resetPasswordButton.addTarget(self, action: #selector(didTapResetPassword), for: .touchUpInside)
    }
    
    /// Function for request by entered email for reset password
    /// - Parameter text: email text from textField input
    private func requestForReset(_ email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [unowned self] errors in
            if let error = errors {
                self.alertError(text: error.localizedDescription)
                self.indicatorView.stopAnimating()
            } else {
                
                let alert = UIAlertController(title: "Important message".localized() , message: "We send you message with detail information. Check mailbox".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .default,handler: { [weak self] _ in
                    if let vc = self?.navigationController?.viewControllers[(self?.navigationController!.viewControllers.count)!-3] {
                        DispatchQueue.main.async {
                            self?.indicatorView.stopAnimating()
                            self?.indicatorView.removeFromSuperview()
                            self?.view.alpha = 1.0
                            self?.navigationController?.popToViewController(vc, animated: isViewAnimated)
                        }
                        
                    }
                }))
                present(alert, animated: isViewAnimated)
            }
        }
    }
    
}
//MARK: - Textfield delegate
extension ResetPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let field = textField.text, !field.isEmpty else { return false}
        if textField.becomeFirstResponder() {
            textField.resignFirstResponder()
            didTapResetPassword()
            return true
        } else {
            return false
        }
    }
}
//MARK: - Extensions
extension ResetPasswordViewController {
    private func setupConstraints(){
        view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-view.frame.size.height/4)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }

        
        view.addSubview(resetPasswordButton)
        resetPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(60)
            make.height.equalTo(40)
        }
    }
}

