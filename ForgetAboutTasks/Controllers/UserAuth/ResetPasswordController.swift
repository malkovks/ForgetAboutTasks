//
//  ResetPasswordController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 30.05.2023.
//

import UIKit
import SnapKit
import FirebaseAuth



class ResetPasswordViewController: UIViewController {
    
    private var isPasswordHidden: Bool = true
    
    //MARK: - UI views
    private let emailTextField: UITextField = {
       let field = UITextField()
        field.placeholder = " Enter your email"
        field.isSecureTextEntry = false
        field.layer.borderWidth = 1
        field.autocapitalizationType = .none
        field.layer.cornerRadius = 12
        field.layer.borderColor = UIColor(named: "navigationControllerColor")?.cgColor
        return field
    }()

    private let resetPasswordButton: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Reset"
        button.layer.cornerRadius = 8
        button.configuration?.baseBackgroundColor = UIColor(named: "textColor")
        button.tintColor = UIColor(named: "textColor")
        return button
    }()
    
    private let indicatorView = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    //MARK: - Targets
    @objc private func didTapResetPassword(){
        setupHapticMotion(style: .medium)
        let auth = Auth.auth()
        guard let text = emailTextField.text, !text.isEmpty else { alertError(text: "Enter email"); return }
        
        auth.sendPasswordReset(withEmail: text) { [weak self] errors in
            if let error = errors {
                self?.alertError(text: error.localizedDescription, mainTitle: "Error")
            } else {
                self?.showAlertForUser(text: "Hurray!\nCheck your email box", duration: DispatchTime.now()+2, controllerView: (self?.view)!)
            }
        }
    }
    
    //MARK: - Set up methods
    private func setupView(){
        setupConstraints()
        setupNavigationController()
        setupTargets()
        emailTextField.resignFirstResponder()
        view.backgroundColor = UIColor(named: "launchBackgroundColor")
    }
    
    private func setupNavigationController(){
        title = "Password recovery"
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
    }
    
    private func setupTargets(){
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

