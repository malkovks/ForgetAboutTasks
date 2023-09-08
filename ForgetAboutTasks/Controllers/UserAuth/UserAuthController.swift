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

/// Class display main setup for Login to application with possibility to enter with login, creating account or enter with google account
class UserAuthViewController: UIViewController {
    
    private let textInfo: String = "This application using Firebase Authentication for entering, creating and storing user email and password. However our service using Keychain API for storing email and password, it store in UTF8 format and closed for third-persons can't be available. \nFor more information, visit Firebase.Google.com".localized()

    //MARK: - UI views
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Log In".localized()
        button.configuration?.baseBackgroundColor = UIColor(named: "calendarHeaderColor")
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Create New Account".localized()
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        button.configuration?.baseBackgroundColor = UIColor(named: "calendarHeaderColor")
        return button
    }()
    
    private let anotherAuthLabel: UILabel = {
       let label = UILabel()
        label.text = "Or".localized()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18,weight: .thin)
        label.textColor = UIColor(named: "textColor")
        return label
    }()
    
    private let signWithGoogle: UIButton = {
        let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Sign in with Google".localized()
        button.configuration?.image = UIImage(named: "google_logo")
        button.configuration?.imagePadding = 8
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        button.configuration?.baseBackgroundColor = UIColor(named: "loginColor")
        button.layer.cornerRadius = 8
        button.tintColor = .systemBackground
        return button
    }()
    
    private lazy var infoNavigationItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "info.circle.fill"), style: .done, target: self, action: #selector(didTapOpenInfo))
    }()
    
    private let spinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //MARK: - Targets methods
    @objc private func didTapOpenInfo(){
        showInfoAuthentication(text: textInfo, controller: view)
    }
    
    @objc private func didTapLogin(){
        setupHapticMotion(style: .soft)
        let vc = LogInViewController()
        navigationController?.pushViewController(vc, animated: isViewAnimated)
    }
    
    @objc private func didTapRegister(){
        setupHapticMotion(style: .soft)
        let vc = RegisterAccountViewController()
        navigationController?.pushViewController(vc, animated: isViewAnimated)
    }
    
    @objc private func didTapLoginWithGoogle(){
        setupHapticMotion(style: .soft)
        spinner.startAnimating()
        view.alpha = 0.8
        guard let client = FirebaseApp.app()?.options.clientID else {
            alertError(text: "Error getting access to Firebase servers.\nTry again later".localized(), mainTitle: "Error".localized())
            return
        }
        googleAuthentication(client)
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
        tabBarController?.tabBar.isHidden = true
        title = "Authorization".localized()
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = infoNavigationItem
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
    }
    
    private func setupTargets() {
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        signWithGoogle.addTarget(self, action: #selector(didTapLoginWithGoogle), for: .touchUpInside)
    }
    
    /// function for check input clients id if Firebase available for user
    /// - Parameter client: users identical id
    private func googleAuthentication(_ client: String) {
        //create google sign in configuration object
        let config = GIDConfiguration(clientID: client)
        GIDSignIn.sharedInstance.configuration = config
        //start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                self.spinner.stopAnimating()
                self.view.alpha = 1.0
                self.alertError(text: error?.localizedDescription ?? "")
                return
            }
            guard let user = result?.user,
                  let token = user.idToken?.tokenString else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: token, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                guard let result = result, error == nil else {
                    self.alertError(text: "Error getting data from account".localized(), mainTitle: "Error!".localized())
                    return
                }
                UserDefaultsManager.shared.saveAccountData(result: result, user: user)
                
                self.dismiss(animated: isViewAnimated)
                self.navigationController?.popToRootViewController(animated: isViewAnimated)
                self.spinner.stopAnimating()
                self.view.alpha = 1.0
            }
        }
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
