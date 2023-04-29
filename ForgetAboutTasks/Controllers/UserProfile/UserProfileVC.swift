//
//  UserProfileViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
//

import UIKit
import FirebaseAuth
import SnapKit

struct UserProfileData {
    var cellName: String
    var cellImage: UIImage
}

class UserProfileViewController: UIViewController {
    
//    var cellArray = [["Dark Mode","Background Color","Access to Notifications"],["Language","In future test variations","Information"]]
    
    var cellArray = [[UserProfileData(cellName: "Dark Mode", cellImage: UIImage(systemName: "moon.fill")!),
                     UserProfileData(cellName: "Background Color", cellImage: UIImage(systemName: "circle.fill")!),
                     UserProfileData(cellName: "Access to Notifications", cellImage: UIImage(systemName: "headphones.circle.fill")!)],[
                        UserProfileData(cellName: "Language", cellImage: UIImage(systemName: "keyboard.fill")!),
                     UserProfileData(cellName: "Futures", cellImage: UIImage(systemName: "clock.fill")!),
                     UserProfileData(cellName: "Information", cellImage: UIImage(systemName: "info.circle.fill")!)]]
    
    private var imagePicker = UIImagePickerController()
    private let scrollView = UIScrollView()
    private let tableView = UITableView()
    
    private let profileView: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.3920767307, green: 0.5687371492, blue: 0.998278439, alpha: 1)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let userImageView: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
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
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.backgroundColor = .clear
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let mailLabel: UILabel = {
        let label = UILabel()
        label.text = "User email"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.backgroundColor = .clear
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "Press to set user's age"
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.backgroundColor = .clear
        label.layer.cornerRadius = 12
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userImageView.layer.cornerRadius = 0.5 * userImageView.bounds.size.width
        scrollView.frame = view.bounds
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
            self.userImageView.sizeToFit()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapTapOnLabel(sender: UITapGestureRecognizer){
        alertNewName(title: "Enter new name and second name", placeholder: "Enter the text") { [weak self] text in
            self?.userNameLabel.text = text
            UserDefaults.standard.set(text, forKey: "userName")
        }
    }
    
    @objc private func didTapOnAge(sender: UITapGestureRecognizer){
        alertNewName(title: "Enter your age", placeholder: "Enter age number") { [weak self] text in
            self?.ageLabel.text = text
            UserDefaults.standard.set(text, forKey: "userAge")
        }
    }
    
    @objc private func didTapSwitch(sender: UISwitch){
        if sender.isOn {
            print("is on")
        } else {
            print("is off")
        }
    }
    
    
    //MARK: - Setup methods
    private func setupView(){
        setupNavigationController()
        configureConstraints()
        setupDelegates()
        setupTapGestureForImage()
        setupTargets()
        setTapGestureForLabel()
        setTapGestureForAgeLabel()
        loadingData()
        setupScrollView()
        setupTableView()
        view.backgroundColor = .secondarySystemBackground
    }
    
    private func setupScrollView(){
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
    }
    
    private func setupTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsIdentifier")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 8
    }
    
    private func loadingData(){
        let (name,mail,age,image) = CheckAuth.shared.loadData()
        userImageView.image = image
        mailLabel.text = mail
        ageLabel.text = "User's age: \(age)"
        userNameLabel.text = name
    }
    
    private func setupNavigationController(){
        title = "My Profile"
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.9751130939, green: 0.9366052747, blue: 0.9639498591, alpha: 1)
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
        userNameLabel.isUserInteractionEnabled = true
        userNameLabel.addGestureRecognizer(tap)
    }
    
    private func setTapGestureForAgeLabel(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnAge))
        ageLabel.isUserInteractionEnabled = true
        ageLabel.addGestureRecognizer(tap)
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
        self.mailLabel.text = result.user.email ?? ""
    }
}

extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1: return 3
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Main setups"
        case 1: return "Secondary setups"
        default: return "Error"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "settingsIdentifier")
        let data = cellArray[indexPath.section][indexPath.row]
        let switchButton = UISwitch()
        switchButton.isOn = false
        switchButton.onTintColor = #colorLiteral(red: 0.3920767307, green: 0.5687371492, blue: 0.998278439, alpha: 1)
        switchButton.isHidden = true
        switchButton.addTarget(self, action: #selector(self.didTapSwitch(sender: )), for: .touchUpInside)
        cell.accessoryView = switchButton
        if indexPath.section == 0 {
            switchButton.isHidden = false
        } else {
            cell.accessoryType = .detailDisclosureButton
        }
        
        cell.layer.cornerRadius = 10
        cell.textLabel?.text = data.cellName
        cell.imageView?.image = data.cellImage
        return cell
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
        
        let imageStackView = UIStackView(arrangedSubviews: [userImageView,changeUserImageView])
        imageStackView.spacing = 10
        imageStackView.alignment = .center
        imageStackView.contentMode = .center
        imageStackView.axis = .vertical

        let infoStack = UIStackView(arrangedSubviews: [userNameLabel,mailLabel,ageLabel])
        infoStack.alignment = .leading
        infoStack.contentMode = .scaleAspectFit
        infoStack.axis = .vertical
        infoStack.spacing = 20
        
        view.addSubview(profileView)
        profileView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
        }
        
        profileView.addSubview(imageStackView)
        imageStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(10)
            make.width.equalTo(110)
            make.height.equalTo(150)
        }
        
        profileView.addSubview(infoStack)
        infoStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.trailing.equalToSuperview().inset(-10)
            make.leading.equalTo(imageStackView.snp.trailing).offset(30)
            make.height.equalTo(110)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }

        
    }
}
