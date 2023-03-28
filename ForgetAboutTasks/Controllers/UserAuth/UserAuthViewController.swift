//
//  UserAuthViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//

import UIKit
import SnapKit

class UserAuthViewController: UIViewController {
    
    
    //MARK: - UI views
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Log In"
        button.configuration?.baseBackgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        button.configuration?.baseForegroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Create New Account"
        button.configuration?.baseForegroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        button.configuration?.baseBackgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)

        return button
    }()
    
    private let anotherAuthLabel: UILabel = {
       let label = UILabel()
        label.text = "Or"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18,weight: .thin)
        label.textColor = #colorLiteral(red: 0.06544024497, green: 0.06544024497, blue: 0.06544024497, alpha: 1)
        return label
    }()
    
    private let signWithGoogle: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Sign in with Google"
        button.configuration?.image = UIImage(named: "google_logo")
        button.configuration?.imagePadding = 8
        button.layer.cornerRadius = 8
        button.backgroundColor = #colorLiteral(red: 0.06544024497, green: 0.06544024497, blue: 0.06544024497, alpha: 1)
        button.tintColor = .systemBackground
        return button
    }()
    
    private let signWithApple: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Sign in with Apple"
        button.configuration?.image = UIImage(named: "apple_logo")?.withTintColor(.systemBackground,renderingMode: .alwaysOriginal)
        button.configuration?.imagePadding = 8
        button.layer.cornerRadius = 8
        button.backgroundColor = #colorLiteral(red: 0.06544024497, green: 0.06544024497, blue: 0.06544024497, alpha: 1)
        button.tintColor = .systemBackground
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    //MARK: - Targets methods
    @objc private func didTapDismiss(){
        self.dismiss(animated: true)
    }
    
    @objc private func didTapLogin(){
        let vc = LogInViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .flipHorizontal
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterAccountViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .flipHorizontal
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
        
    }
    //MARK: - Setup methods
    private func setupView(){
        setupNavigation()
        setupConstraints()
        setupTargets()
        view.backgroundColor = .secondarySystemBackground
    }
    
    private func setupNavigation(){
        title = "Authorization"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTargets() {
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }
    
    
    
}
//MARK: - Extensions
extension UserAuthViewController {
    private func setupConstraints(){
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(55)
        }
        view.addSubview(registerButton)
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(55)
        }
        
        view.addSubview(anotherAuthLabel)
        anotherAuthLabel.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        view.addSubview(signWithGoogle)
        signWithGoogle.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(50)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(55)
        }
        
        view.addSubview(signWithApple)
        signWithApple.snp.makeConstraints { make in
            make.top.equalTo(signWithGoogle.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(55)
        }
    }
}
