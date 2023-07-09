//
//  UserAuthViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//

import UIKit
import SnapKit
import Firebase
import GoogleSignIn


class UserAuthViewController: UIViewController {

    //MARK: - UI views
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Log In"
        button.configuration?.baseBackgroundColor = UIColor(named: "calendarHeaderColor")
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Create New Account"
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        button.configuration?.baseBackgroundColor = UIColor(named: "calendarHeaderColor")
        return button
    }()
    
    private let anotherAuthLabel: UILabel = {
       let label = UILabel()
        label.text = "Or"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18,weight: .thin)
        label.textColor = UIColor(named: "textColor")
        return label
    }()
    
    private let signWithGoogle: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Sign in with Google"
        button.configuration?.image = UIImage(named: "google_logo")
        button.configuration?.imagePadding = 8
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        button.configuration?.baseBackgroundColor = UIColor(named: "loginColor")
        button.layer.cornerRadius = 8
        button.tintColor = .systemBackground
        return button
    }()
    
    private let spinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //MARK: - Targets methods
    @objc private func didTapLogin(){
        let vc = LogInViewController()
        show(vc, sender: nil)
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterAccountViewController()
        show(vc, sender: nil)
    }
    
    @objc private func didTapLoginWithGoogle(){
        spinner.startAnimating()
        view.alpha = 0.8
        guard let client = FirebaseApp.app()?.options.clientID else {
            print("Error client id")
            return
        }
        
        //
        //create google sign in configuration object
        let config = GIDConfiguration(clientID: client)
        GIDSignIn.sharedInstance.configuration = config
        //start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                self.spinner.stopAnimating()
                self.view.alpha = 1.0
                return
            }
            guard let user = result?.user,
                  let token = user.idToken?.tokenString else {
                print("Error getting user data and token data")
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: token, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                guard let result = result, error == nil else {
                    self.alertError(text: "Error getting data from account", mainTitle: "Attention")
                    return
                }
                UserDefaultsManager.shared.setupForAuth()
                UserDefaultsManager.shared.saveData(result: result, user: user)
                self.dismiss(animated: true)
                self.spinner.stopAnimating()
                self.view.alpha = 1.0
            }
        }
    }
    //MARK: - Setup methods
    private func setupView(){
        setupNavigation()
        setupConstraints()
        setupTargets()
        spinner.hidesWhenStopped = true
        view.backgroundColor = UIColor(named: "launchBackgroundColor")
    }
    
    private func setupNavigation(){
        title = "Authorization"
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
    }
    
    private func setupTargets() {
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        signWithGoogle.addTarget(self, action: #selector(didTapLoginWithGoogle), for: .touchUpInside)
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
        
        view.addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.width.height.equalTo(50)
        }
    }
}
