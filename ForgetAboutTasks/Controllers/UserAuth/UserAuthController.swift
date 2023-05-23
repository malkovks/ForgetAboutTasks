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

protocol UserAuthProtocol: AnyObject {
    func userData(result: AuthDataResult)
}

class UserAuthViewController: UIViewController {
    
    weak var delegate: UserAuthProtocol?
    
    private let spinner = UIActivityIndicatorView()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
    //MARK: - Targets methods
    @objc private func didTapLogin(){
        spinner.startAnimating()
        view.alpha = 0.8
        let vc = LogInViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .flipHorizontal
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    @objc private func didTapRegister(){
        spinner.startAnimating()
        view.alpha = 0.8
        let vc = RegisterAccountViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .flipHorizontal
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
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
                    self.setupAlert(subtitle: "Error auth.\nTry again!")
                    
                    return
                }
                CheckAuth.shared.setupForAuth()
                CheckAuth.shared.saveData(result: result)
//                self.delegate?.userData(result: result)
                self.dismiss(animated: true)
                self.spinner.stopAnimating()
                self.view.alpha = 1.0
            }
        }
    }
    @objc private func didTapLoginWithGitHub(){
        //not working
    }
    
    //MARK: - Setup methods
    private func setupView(){
        setupNavigation()
        setupConstraints()
        setupTargets()
        spinner.hidesWhenStopped = true
        
        view.backgroundColor = .secondarySystemBackground
    }
    
    private func setupNavigation(){
        title = "Authorization"
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTargets() {
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        signWithGoogle.addTarget(self, action: #selector(didTapLoginWithGoogle), for: .touchUpInside)
    }
    
    private func setupAlert(title: String = "Error!",subtitle: String ){
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert,animated: true)
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
