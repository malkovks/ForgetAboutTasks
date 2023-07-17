//
//  UserProfileViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
//

import UIKit
import FirebaseAuth
import SnapKit
import UserNotifications
import EventKit
import LocalAuthentication
import Contacts
import Photos


struct UserProfileData {
    var title: String
    var cellImage: UIImage
    var cellImageColor: UIColor
}

class UserProfileViewController: UIViewController {

    var cellArray = [[
                        UserProfileData(title: "Dark Mode".localized(),
                                        cellImage: UIImage(systemName: "moon.fill")!,
                                        cellImageColor: .purple),
                        UserProfileData(title: "Access to Notifications".localized(),
                                        cellImage: UIImage(systemName: "bell.square.fill")!,
                                        cellImageColor: .systemRed),
                        UserProfileData(title: "Access to Calendar's Event".localized(),
                                        cellImage: UIImage(systemName: "calendar.badge.clock")!,
                                        cellImageColor: .systemRed),
                        UserProfileData(title: "Access to Contacts",
                                        cellImage: UIImage(systemName: "character.book.closed.fill")!,
                                        cellImageColor: .systemBrown ),
                        UserProfileData(title: "Access to Photo and Camera",
                                        cellImage: UIImage(systemName: "camera.circle")!,
                                        cellImageColor: UIColor(named: "textColor")! ),
                        UserProfileData(title: "Access to Face ID",
                                        cellImage: UIImage(systemName: "faceid")!,
                                        cellImageColor: .systemBlue),
                        UserProfileData(title: "Code-password and Face ID".localized(),
                                        cellImage: UIImage(systemName: "lock.fill")!,
                                        cellImageColor: .systemBlue)
                     ],
                     [
                        UserProfileData(title: "Change App Icon".localized(),
                                        cellImage: UIImage(systemName: "app.fill")!,
                                        cellImageColor: .systemBlue),
                        UserProfileData(title: "Change Font Size".localized(),
                                        cellImage: UIImage(systemName: "character.cursor.ibeam")!,
                                        cellImageColor: .systemIndigo)
                     ],
                     [
                        UserProfileData(title: "Language".localized(),
                                        cellImage: UIImage(systemName: "keyboard.fill")!,
                                        cellImageColor: .systemGreen),
                        UserProfileData(title: "Futures".localized(),
                                        cellImage: UIImage(systemName: "clock.fill")!,
                                        cellImageColor: .systemGreen),
                        UserProfileData(title: "Information".localized(),
                                        cellImage: UIImage(systemName: "info.circle.fill")!,
                                        cellImageColor: .systemGray)],
                     [
                        UserProfileData(title: "Delete Account".localized(),
                                        cellImage: UIImage(systemName: "trash.fill")!,
                                        cellImageColor: .systemRed),
                        UserProfileData(title: "Log Out".localized(),
                                        cellImage: UIImage(systemName: "arrow.uturn.right.square.fill")!,
                                        cellImageColor: .systemRed)
                     ]]

    private var passwordBoolean = UserDefaults.standard.bool(forKey: "isPasswordCodeEnabled")
    private let fontSizeValue : CGFloat = CGFloat(UserDefaults.standard.float(forKey: "fontSizeChanging"))
    private let notificationCenter = UNUserNotificationCenter.current()
    private let provider = DataProvider()
    private let eventStore: EKEventStore = EKEventStore()
    private let semaphore = DispatchSemaphore(value: 0)
    private let userInterface = UserDefaultsManager.shared
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
 //MARK: - UI Elements
    private var imagePicker = UIImagePickerController()
    private let scrollView = UIScrollView()
    private let tableView = UITableView(frame: CGRectZero, style: .insetGrouped)
    
    private let profileView: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.3920767307, green: 0.5687371492, blue: 0.998278439, alpha: 1)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let userImageView: UIImageView = {
        let image = UIImageView(frame: .zero)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = UIColor(named: "backgroundColor")
        image.layer.cornerRadius = image.frame.size.width/2
        image.layer.masksToBounds = true
        image.clipsToBounds = true
        image.layer.borderWidth = 1.0
        image.layer.borderColor = UIColor(named: "textColor")?.cgColor
        image.image = UIImage(systemName: "photo.circle")
        image.tintColor = .black
        return image
    }()
    
    private let changeUserImageView: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Set new image".localized(), for: .normal)
        button.setTitleColor(UIColor(named: "textColor"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        return button
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Press to set name of user".localized()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.backgroundColor = .clear
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let mailLabel: UILabel = {
        let label = UILabel()
        label.text = "User email".localized()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.backgroundColor = .clear
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "Press to set user's age".localized()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.backgroundColor = .clear
        label.layer.cornerRadius = 12
        return label
    }()
 //MARK: - Load cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setupView()
//        tableView.reloadData()
//    }
    //MARK: - Targets methods
    @objc private func didTapLogout(){
        let alert = UIAlertController(title: "Warning", message: "Do you want to Exit from your account?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive,handler: { _ in
            if UserDefaults.standard.bool(forKey: "isAuthorised"){
                UserDefaults.standard.set(false, forKey: "isAuthorised")
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    UserDefaultsManager.shared.signOut()
                } catch let error {
                    print("Error signing out from Firebase \(error)")
                }
                self.view.window?.rootViewController?.dismiss(animated: true)
                let vc = UserAuthViewController()
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
        view.alpha = 0.7
        let alert = UIAlertController(title: nil, message: "What exactly do you want to do?".localized(), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Set new image".localized(), style: .default,handler: { [self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                activityIndicator.startAnimating()
                present(self.imagePicker, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Make new image".localized(), style: .default,handler: { [self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                activityIndicator.startAnimating()
                present(self.imagePicker, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Delete image".localized(), style: .destructive,handler: { _ in
            self.userImageView.image = UIImage(systemName: "photo.circle")
            self.userImageView.sizeToFit()
            UserDefaults.standard.set(nil,forKey: "userImage")
            self.view.alpha = 1
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel,handler: { _ in
            self.view.alpha = 1
            self.activityIndicator.stopAnimating()
        }))
        present(alert, animated: true)
    }
    
    @objc private func didTapOnName(sender: UITapGestureRecognizer){
        alertNewName(title: "Enter new name and second name".localized(),
                     placeholder: "Enter the text".localized()) { [weak self] text in
            self?.userNameLabel.text = text
            UserDefaults.standard.set(text, forKey: "userName")
        }
    }
    
    @objc private func didTapOnAge(sender: UITapGestureRecognizer){
        alertNewName(title: "Enter your age".localized(),
                     placeholder: "Enter age number".localized(),
                     type: .numberPad) { [weak self] text in
            self?.ageLabel.text = "Age: ".localized() + text
            UserDefaults.standard.set(text, forKey: "userAge")
        }
    }
    
    @objc private func didTapSwitch(sender: UISwitch){
        let interfaceStyle: UIUserInterfaceStyle = sender.isOn ? .dark : .light
        UIView.animate(withDuration: 0.5) {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = interfaceStyle
                if let _ = window.windowScene?.delegate as? SceneDelegate {
                    UserDefaults.standard.setValue(sender.isOn, forKey: "setUserInterfaceStyle")
                }
            }
        }
    }
    
    @objc private func didTapChangeAccessNotifications(sender: UISwitch){
        DispatchQueue.main.async { [weak self] in
            if !sender.isOn {
                self?.showSettingsForChangingAccess(title: "Switching off access Notifications", message: "Do you want to switch off notifications?") { success in
                    if !success {
                        sender.isOn = true
                    } else {
                        sender.isOn = false
                    }
                }
            } else {
                self?.notificationCenter.requestAuthorization(options: [.alert,.badge,.sound]) { success, error in
                    if success {
                        DispatchQueue.main.async {
                            self?.showAlertForUser(text: "Notifications turn on completely", duration: DispatchTime.now() + 2, controllerView: (self?.view)!)
                            sender.isOn = success
                        }
                    } else {
                        self?.showSettingsForChangingAccess(title: "Switching on Notifications", message: "Do you want to switch on notifications?") { success in
                            if !success {
                                sender.isOn = false
                            } else {
                                sender.isOn = true
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    @objc private func didTapChangeAccessCalendar(sender: UISwitch){
        if !sender.isOn {
            showSettingsForChangingAccess(title: "Switching off access Calendar", message: "Do you want to switch off access to Calendar?") { success in
                if !success {
                    sender.isOn = true
                }
            }
        } else {
            request(forAllowing: eventStore) { success in
                sender.isOn = success
            }
        }
    }
    
    @objc private func didTapChangeAccessToFaceID(sender: UISwitch){
        DispatchQueue.main.async { [weak self] in
            if !sender.isOn {
                self?.showSettingsForChangingAccess(title: "Switching Off Face ID", message: "Do you want to switch off access to Face ID. You could always change access if it will be necessary ") { success in
                    if !success {
                        sender.isOn = true
                    } else {
                        UserDefaults.standard.setValue(false, forKey: "isUserConfirmPassword")
                    }
                }
            } else {
                self?.checkAuthForFaceID { success in
                    sender.isOn = success
                }
            }
        }
    }
    
    @objc private func didTapChangeAccessToContacts(sender: UISwitch){
        DispatchQueue.main.async { [weak self] in
            if !sender.isOn {
                self?.showSettingsForChangingAccess(title: "Switching off access to Contacts", message: "Do you want to switch off access to Contacts? You could always change access if it will be necessary") { success in
                    if !success {
                        sender.isOn = true
                    }
                }
            } else {
                self?.checkAuthForContacts { success in
                    sender.isOn = success 
                }
            }
        }
    }
    
    @objc private func didTapChangeAccessToMedia(sender: UISwitch){
        DispatchQueue.main.async { [weak self] in
            if !sender.isOn {
                self?.showSettingsForChangingAccess(title: "Switching off access to Media", message: "Do you want to switch off access to Media? You could always change access if it will be necessary") { success in
                    if !success {
                        sender.isOn = true
                    }
                }
            } else {
                
            }
        }
    }
 
    //MARK: - Setup methods
    
    private func setupView(){
        setupNavigationController()
        configureConstraints()
        setupFontSize(size: fontSizeValue)
        setupDelegates()
        setupTapGestureForImage()
        setupTargets()
        setTapGestureForLabel()
        setTapGestureForAgeLabel()
        loadingData()

        setupTableView()
        setupLabelUnderline()
        view.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    private func setupTableView(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingsIdentifier")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 8
        tableView.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    private func setupLabelUnderline(){
        guard let labelText = userNameLabel.text, let ageText = ageLabel.text else { return }
        let attributedText = NSAttributedString(string: labelText, attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        let attributedText2 = NSAttributedString(string: ageText, attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        userNameLabel.attributedText = attributedText
        ageLabel.attributedText = attributedText2
        changeUserImageView.titleLabel?.attributedText = attributedText
    }
    
    private func loadingData(){
        let (name,mail,age) = UserDefaultsManager.shared.loadData()
        guard let url = UserDefaults.standard.url(forKey: "userImageURL") else { return }
        
        if let _ = UserDefaults.standard.data(forKey: "userImage") {
            userImageView.image = UserDefaultsManager.shared.loadSettedImage()
        } else {
            provider.dataProvider(url: url) { image in
                self.userImageView.image = image
            }
        }
        
        
        mailLabel.text = mail
        ageLabel.text = "Age: ".localized() + age
        userNameLabel.text = name
    }
    
    private func setupNavigationController(){
        title = "My Profile".localized()
        navigationController?.navigationBar.tintColor = UIColor(named: "textColor")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.right.square"), style: .done, target: self, action: #selector(didTapLogout))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
    }
    
    private func setupDelegates(){
        imagePicker.delegate = self
    }
    
    private func setupTapGestureForImage(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImagePicker))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tap)
    }
    
    private func setTapGestureForLabel(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnName))
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
    
    private func setupFontSize(size: CGFloat){
        ageLabel.font = .systemFont(ofSize: size )
        userNameLabel.font = .systemFont(ofSize: size )
        mailLabel.font = .systemFont(ofSize: size )
        changeUserImageView.titleLabel?.font = .systemFont(ofSize: size )
        userImageView.layer.cornerRadius = userImageView.frame.size.width/2
        tableView.reloadData()
    }
    
    private func setupSwitchDarkMode() -> Bool {
        let windows = UIApplication.shared.windows
        
        if windows.first?.overrideUserInterfaceStyle == .dark {
            UserDefaults.standard.setValue(true, forKey: "setUserInterfaceStyle")
            return true
        } else {
            UserDefaults.standard.setValue(false, forKey: "setUserInterfaceStyle")
            return false
        }
    }

    private func openSelectionChangeIcon(){
        let vc = UserProfileAppIconViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        nav.sheetPresentationController?.detents = [.custom(resolver: { _ in return self.view.frame.size.height/5 })]
        nav.sheetPresentationController?.prefersGrabberVisible = true
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    private func openPasswordController(title: String = "Code-password",message: String = "This function allow you to switch on password if it neccesary. Any time you could change it",alertTitle: String = "Switch on code-password"){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: alertTitle, style: .default,handler: { [weak self] _ in
            self?.passwordBoolean = UserDefaults.standard.bool(forKey: "isPasswordCodeEnabled")
            let vc = UserProfileSwitchPasswordViewController(isCheckPassword: false)
            vc.delegate = self
            self?.show(vc, sender: nil)
        }))
        if passwordBoolean {
            alert.addAction(UIAlertAction(title: "Switch off", style: .default,handler: { [weak self]_ in
                UserDefaults.standard.setValue(false, forKey: "isPasswordCodeEnabled")
                KeychainManager.delete()
                self?.passwordBoolean = UserDefaults.standard.bool(forKey: "isPasswordCodeEnabled")
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func openChangeFontController(){
        let vc = ChangeFontViewController()
        vc.delegate = self
        vc.dataReceive = { [weak self] _ in
            self?.setupView()
            self?.tableView.reloadData()
            print("closure work fine")
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .coverVertical
        nav.isNavigationBarHidden = false
        self.present(nav, animated: true)
    }
    
    
}
//MARK: - Check Success Delegate
extension UserProfileViewController: CheckSuccessSaveProtocol, ChangeFontDelegate {
    func changeFont(font size: CGFloat) {
        setupFontSize(size: size)
        print("delegate work fine")
    }
    
    func isSavedCompletely(boolean: Bool) {
        tabBarController?.tabBar.isHidden = false
        if boolean {
            showAlertForUser(text: "Password was created", duration: .now()+1, controllerView: view)
            passwordBoolean = UserDefaults.standard.bool(forKey: "isPasswordCodeEnabled")
        }
    }
}

//MARK: - Table view delegate and data source
extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return cellArray[section].count
        case 1: return cellArray[section].count
        case 2: return cellArray[section].count
        case 3: return cellArray[section].count
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Main setups".localized()
        case 1: return "Secondary setups".localized()
        case 2: return "Info".localized()
        case 3: return ""
        default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "settingsIdentifier")
        let data = cellArray[indexPath.section][indexPath.row]
        cell.backgroundColor = UIColor(named: "cellColor")
        cell.selectionStyle = .none
        cell.textLabel?.font = .systemFont(ofSize: fontSizeValue ?? 16)
        let switchButton = UISwitch()
        switchButton.isOn = false
        switchButton.onTintColor = #colorLiteral(red: 0.3920767307, green: 0.5687371492, blue: 0.998278439, alpha: 1)
        switchButton.isHidden = true
        switchButton.clipsToBounds = true
        
        cell.accessoryView = switchButton
        if indexPath == [0,0] {
            switchButton.isHidden = false
            switchButton.isOn = userInterface.checkDarkModeUserDefaults() ?? setupSwitchDarkMode()
            cell.accessoryType = .none
            switchButton.addTarget(self, action: #selector(self.didTapSwitch(sender: )), for: .touchUpInside)
        } else if indexPath == [0,1] {
            switchButton.isHidden = false
            cell.accessoryType = .none
            switchButton.addTarget(self, action: #selector(didTapChangeAccessNotifications), for: .touchUpInside)
            showNotificationAccessStatus { access in
                DispatchQueue.main.async {
                    switchButton.isOn = access
                }
            }
        } else if indexPath == [0,2] {
            switchButton.isHidden = false
            cell.accessoryType = .none
            switchButton.addTarget(self, action: #selector(didTapChangeAccessCalendar), for: .touchUpInside)
            request(forAllowing: eventStore) { access in
                DispatchQueue.main.async {
                    switchButton.isOn = access
                }
            }
        } else if indexPath == [0,3] {
            switchButton.isHidden = false
            cell.accessoryType = .none
            switchButton.addTarget(self, action: #selector(didTapChangeAccessToContacts), for: .touchUpInside)
            checkAuthForContacts { success in
                DispatchQueue.main.async {
                    switchButton.isOn = success
                }
            }
        } else if indexPath == [0,4] {
            switchButton.isHidden = false
            cell.accessoryType = .none
            switchButton.addTarget(self, action: #selector(didTapChangeAccessToMedia), for: .touchUpInside)
            checkAccessForMedia { success in
                DispatchQueue.main.async {
                    switchButton.isOn = success
                }
            }
        } else if indexPath == [0,5] {
            switchButton.isHidden = false
            cell.accessoryType = .none
            switchButton.addTarget(self, action: #selector(didTapChangeAccessToFaceID), for: .touchUpInside)
            checkAuthForFaceID { success in
                DispatchQueue.main.async {
                    switchButton.isOn = success
                }
            }
        } else {
            cell.accessoryView = .none
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .blue
        }
        
        cell.textLabel?.text = data.title
        cell.imageView?.image = data.cellImage
        cell.imageView?.tintColor = data.cellImageColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case [0,6]:
            if passwordBoolean {
                openPasswordController(title: "Warning!", message: "Do you want to switch off or change password?", alertTitle: "Change password")
            } else {
                openPasswordController()
            }
            
        case [1,0]:
            openSelectionChangeIcon()
        case [1,1]:
            openChangeFontController()
        case [2,0]:
            showSettingsForChangingAccess(title: "Changing App Language".localized(),
                                          message: "Would you like to change the language of your application?".localized()) { _ in }
            
        case [3,0]:
            print("Delete")
        case [3,1]:
            didTapLogout()
        default:
            print("Error")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        fontSizeValue * 4
    }
    
    
}

extension UserProfileViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            guard let data = image.jpegData(compressionQuality: 0.5) else { return}
            let encode = try! PropertyListEncoder().encode(data)
            UserDefaults.standard.setValue(encode, forKey: "userImage")
            UserDefaults.standard.set(nil, forKey: "userImageURL")
            userImageView.image = image
        } else {
            print("Error")
        }
        picker.dismiss(animated: true)
        activityIndicator.stopAnimating()
        view.alpha = 1
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        view.alpha = 1
        
    }
}

extension UserProfileViewController  {
    private func configureConstraints(){

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
        
        profileView.addSubview(userImageView)
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.width.equalTo(110)
            make.height.equalTo(110)
        }
        
        profileView.addSubview(changeUserImageView)
        changeUserImageView.snp.makeConstraints { make in
            make.bottom.equalTo(profileView.snp.bottom).offset(-30)
            make.leading.equalToSuperview().offset(30)
            make.width.equalTo(110)
        }
        
        profileView.addSubview(infoStack)
        infoStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.trailing.equalToSuperview().inset(-10)
            make.leading.equalTo(userImageView.snp.trailing).offset(10)
            make.height.equalTo(110)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        
    }
}
