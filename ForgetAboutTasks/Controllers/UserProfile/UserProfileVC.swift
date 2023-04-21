//
//  UserProfileViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
//

import UIKit
import FirebaseAuth
import SnapKit

class UserProfileViewController: UIViewController {
    
    private var imagePicker = UIImagePickerController()
    
    private let userImageView: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.backgroundColor = .secondarySystemBackground
        image.layer.cornerRadius = image.frame.size.width/2
        image.clipsToBounds = true
        image.image = UIImage(systemName: "photo.circle")
        image.tintColor = .black
        return image
    }()
    
    private let changeUserImageView: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change image", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        return button
    }()
    
    private let userNameLabel: UILabel = {
       let label = UILabel()
        label.text = "Press to set name of user"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = 12
        return label
    }()
    
    
    
    private let userMailLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .thin)
        label.text = "User's email address"
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let settingsLabel: UILabel = {
       let label = UILabel()
        label.text = "Settings"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.backgroundColor = .secondarySystemBackground
        label.numberOfLines = 1
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.layer.cornerRadius = 0.5 * userImageView.bounds.size.width
    }
    
    @objc private func didTapLogout(){
        let alert = UIAlertController(title: "Warning", message: "Do you want to Exit from your account?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive,handler: { _ in
            if UserDefaults.standard.bool(forKey: "isAuthorised"){
                UserDefaults.standard.set(false, forKey: "isAuthorised")
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                } catch let error {
                    print("Error signing out from Firebase \(error)")
                }
                self.view.window?.rootViewController?.dismiss(animated: true)
                let vc = UserAuthViewController()
                vc.delegate = self
                let navVC = UINavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen
                navVC.isNavigationBarHidden = false
                self.present(navVC, animated: true)
            } else {
                print("Error exiting from account")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapImagePicker(){
        let alert = UIAlertController(title: "", message: "What exactly do you want to do?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Set new image", style: .default,handler: { [self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                present(self.imagePicker, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Make new image", style: .default,handler: { [self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                present(self.imagePicker, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Delete image", style: .destructive,handler: { _ in
            self.userImageView.image = UIImage(systemName: "photo.circle")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapTapOnLabel(sender: UITapGestureRecognizer){
        print("Label selected")
    }
    
    
    //MARK: - Setup methods
    private func setupView(){
        setupNavigationController()
        configureConstraints()
        setupDelegates()
        setupTapGestureForImage()
        setupTargets()
        setTapGestureForLabel()
        loadingData()
        view.backgroundColor = .secondarySystemBackground
    }
    
    private func loadingData(){
        let (name,mail,image) = CheckAuth.shared.loadData()
        userImageView.image = image
        userNameLabel.text = name
        userMailLabel.text = mail
    }
    
    private func setupNavigationController(){
        title = "My Profile"
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.right.square"), style: .done, target: self, action: #selector(didTapLogout))
    }

    private func setupDelegates(){
        let vc = UserAuthViewController()
        vc.delegate = self
        imagePicker.delegate = self
        
    }
    
    private func setupTapGestureForImage(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImagePicker))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tap)
    }
    
    private func setTapGestureForLabel(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapTapOnLabel))
        userMailLabel.isUserInteractionEnabled = true
        userMailLabel.addGestureRecognizer(tap)
    }
    
    private func setupTargets(){
        changeUserImageView.addTarget(self, action: #selector(didTapImagePicker), for: .touchUpInside)
    }
    

}

extension UserProfileViewController: UserAuthProtocol {
    func userData(result: AuthDataResult) {
        CheckAuth.shared.saveData(result: result)
        guard let imageURL = result.user.photoURL else { print("Error");return}
        downloadImage(url: imageURL) { [weak self] data in
            let image = UIImage(data: data)
            self?.userImageView.image = image
        }
        self.userNameLabel.text = result.user.displayName ?? "Unavaliable name"
        self.userMailLabel.text = result.user.email ?? ""
    }
    
    
}

extension UserProfileViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            guard let data = image.jpegData(compressionQuality: 0.5) else { print("error saving");return}
            let encode = try! PropertyListEncoder().encode(data)
            UserDefaults.standard.set(encode, forKey: "userImage")
            userImageView.image = image
        } else {
            print("Error")
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension UserProfileViewController  {
    private func configureConstraints(){
        view.addSubview(userImageView)
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.height.width.equalTo(100)
            make.centerX.equalToSuperview()
            
        }
        
        view.addSubview(changeUserImageView)
        changeUserImageView.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(5)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(100)
        }
        
        view.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(changeUserImageView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.leading.trailing.equalToSuperview().inset(50)
        }
        
        view.addSubview(userMailLabel)
        userMailLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(40)
        }
        
        view.addSubview(settingsLabel)
        settingsLabel.snp.makeConstraints { make in
            make.top.equalTo(userMailLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(30)
        }
        // начать думать как хранить словарь в coredata (или в firebase)
    }
}
