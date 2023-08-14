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
                                        cellImageColor: .systemIndigo),
                        UserProfileData(title: "Change Font".localized(),
                                        cellImage: UIImage(systemName: "character.cursor.ibeam")!,
                                        cellImageColor: .systemIndigo),
                        UserProfileData(title: "Enable Animation",
                                        cellImage: UIImage(systemName: "figure.walk.motion")!,
                                        cellImageColor: .systemGreen),
                        UserProfileData(title: "Enable vibration",
                                        cellImage: UIImage(systemName: "iphone.gen2.radiowaves.left.and.right")!,
                                        cellImageColor: .black)
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
    private let notificationCenter = UNUserNotificationCenter.current()
    private let provider = DataProvider()
    private let eventStore: EKEventStore = EKEventStore()
    private let semaphore = DispatchSemaphore(value: 0)
    private let userInterface = UserDefaultsManager.shared
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let windows = UIApplication.shared.windows
    
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
        image.sizeToFit()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = UIColor(named: "backgroundColor")
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
        button.setTitle("Set image".localized(), for: .normal)
        button.setTitleColor(UIColor(named: "textColor"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        return button
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Press to set name of user".localized()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.backgroundColor = .clear
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let mailLabel: UILabel = {
        let label = UILabel()
        label.text = "User email".localized()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.backgroundColor = .clear
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "Press to set user's age".localized()
        label.numberOfLines = 1
        label.textAlignment = .left
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    //MARK: - Targets methods
    @objc private func didTapLogout(){
        setupHapticMotion(style: .soft)
        let alert = UIAlertController(title: "Warning", message: "Do you want to Exit from your account?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive,handler: {  [weak self] _ in
            if UserDefaults.standard.bool(forKey: "isAuthorised"){
                UserDefaults.standard.set(false, forKey: "isAuthorised")
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    UserDefaultsManager.shared.signOut()
                } catch let error {
                    print("Error signing out from Firebase \(error)")
                }
                self?.view.window?.rootViewController?.dismiss(animated: isViewAnimated)
                let vc = UserAuthViewController()
                let navVC = UINavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .fullScreen
                navVC.isNavigationBarHidden = false
                self?.present(navVC, animated: isViewAnimated)
            } else {
                print("Error exiting from account")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: isViewAnimated)
    }
    
    @objc private func didTapImagePicker(){
        setupHapticMotion(style: .soft)
        view.alpha = 0.7
        let alert = UIAlertController(title: nil, message: "What exactly do you want to do?".localized(), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Set new image".localized(), style: .default,handler: { [self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                activityIndicator.startAnimating()
                present(self.imagePicker, animated: isViewAnimated)
            }
        }))
        alert.addAction(UIAlertAction(title: "Make new image".localized(), style: .default,handler: { [self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                activityIndicator.startAnimating()
                present(self.imagePicker, animated: isViewAnimated)
            }
        }))
        alert.addAction(UIAlertAction(title: "Delete image".localized(), style: .destructive,handler: { _ in
            self.userImageView.image = UIImage(systemName: "photo.circle")
            UserDefaults.standard.set(nil,forKey: "userImage")
            self.view.alpha = 1
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel,handler: { _ in
            self.view.alpha = 1
            self.activityIndicator.stopAnimating()
        }))
        present(alert, animated: isViewAnimated)
    }
    
    @objc private func didTapOnName(sender: UITapGestureRecognizer){
        setupHapticMotion(style: .soft)
        alertNewName(title: "Enter new name and second name".localized(),
                     placeholder: "Enter the text".localized()) { [weak self] text in
            self?.userNameLabel.text = text
            UserDefaults.standard.set(text, forKey: "userName")
        }
    }
    
    @objc private func didTapOnAge(sender: UITapGestureRecognizer){
        setupHapticMotion(style: .soft)
        alertNewName(title: "Enter your age".localized(),
                     placeholder: "Enter age number".localized(),
                     type: .numberPad) { [weak self] text in
            self?.ageLabel.text = "Age: ".localized() + text
            UserDefaults.standard.set(text, forKey: "userAge")
        }
    }
    
    @objc private func didTapSwitchDisplayMode(sender: UISwitch){
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
                        UserDefaults.standard.setValue(false, forKey: "accessToFaceID")
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
 
    @objc private func didTapDisableAnimation(sender: UISwitch){
        DispatchQueue.main.async {
            UserDefaults.standard.setValue(sender.isOn, forKey: "enabledAnimation")
        }
    }
    
    @objc private func didTapChangeNapticStyle(sender: UISwitch){
        DispatchQueue.main.async {
            UserDefaults.standard.setValue(sender.isOn, forKey: "enableVibration")
        }
    }

    @objc private func didTapDismissView(){
        tabBarController?.tabBar.isHidden = false
        print("Work fine")
    }
    
    
    
    //MARK: - Setup methods
    
    private func setupView(){
        setupNavigationController()
        configureConstraints()
        setupFontSize()
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
        tableView.register(UserProfileTableViewCell.self, forCellReuseIdentifier: UserProfileTableViewCell.identifier)
        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 8
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.separatorStyle = .none
        //debag
        tableView.canCancelContentTouches = true
        tableView.delaysContentTouches = false
        tableView.panGestureRecognizer.isEnabled = false
        
    }
    
    private func setupLabelUnderline(){
        guard let labelText = userNameLabel.text, let ageText = ageLabel.text else { return }
        let attributedText = NSAttributedString(string: labelText, attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        let attributedText2 = NSAttributedString(string: ageText, attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        userNameLabel.attributedText = attributedText
        ageLabel.attributedText = attributedText2
        changeUserImageView.titleLabel?.attributedText = attributedText
    }
    
    private func setupNavigationController(){
        title = "My Profile".localized()
        navigationController?.navigationBar.tintColor = UIColor(named: "textColor")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.right.square"), style: .done, target: self, action: #selector(didTapLogout))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(didTapDismissView))
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
    
    private func setupFontSize(){
        ageLabel.font = .setMainLabelFont()
        userNameLabel.font = .setMainLabelFont()
        mailLabel.font = .setMainLabelFont()
        changeUserImageView.titleLabel?.font = .setMainLabelFont()
        tableView.reloadData()
    }
    //setup size of image 
    private func imageWith(image: UIImage) -> UIImage {
        let newSize = CGSize(width: image.size.width/2, height: image.size.height/2)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage(systemName: "square.fill")!
    }
    
    //loading data
    private func loadingData(){
        let (name,mail,age) = UserDefaultsManager.shared.loadData()
        if let url = UserDefaults.standard.url(forKey: "userImageURL"){
            provider.dataProvider(url: url) { [weak self] image in
                let convertedImage = self?.imageWith(image: image ?? UIImage())
                self?.userImageView.image = convertedImage
            }
        } else {
            let image = UserDefaultsManager.shared.loadSettedImage()
            let convertedImage = imageWith(image: image)
            userImageView.image = convertedImage
        }
        
        
        mailLabel.text = mail
        ageLabel.text = "Age: ".localized() + age
        userNameLabel.text = name
    }
    
    
    //Setup segue to another ViewController
    private func openSelectionChangeIcon(){
        setupHapticMotion(style: .soft)
        let vc = UserProfileAppIconViewController()
        vc.checkSelectedIcon = { [weak self] value in
            if value == true {
                self?.tableView.reloadData()
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        nav.sheetPresentationController?.detents = [.custom(resolver: { _ in return self.view.frame.size.height/5 })]
        nav.sheetPresentationController?.prefersGrabberVisible = true
        nav.isNavigationBarHidden = false
        present(nav, animated: isViewAnimated)
    }
    
    private func openPasswordController(title: String = "Code-password",message: String = "This function allow you to switch on password if it neccesary. Any time you could change it",alertTitle: String = "Switch on code-password"){
        setupHapticMotion(style: .soft)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: alertTitle, style: .default,handler: { [unowned self] _ in
            self.passwordBoolean = UserDefaults.standard.bool(forKey: "isPasswordCodeEnabled")
            let vc = UserProfileSwitchPasswordViewController(isCheckPassword: false)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: isViewAnimated)
        }))
        if passwordBoolean {
            alert.addAction(UIAlertAction(title: "Switch off", style: .default,handler: { [weak self]_ in
                UserDefaults.standard.setValue(false, forKey: "isPasswordCodeEnabled")
                KeychainManager.delete()
                self?.passwordBoolean = UserDefaults.standard.bool(forKey: "isPasswordCodeEnabled")
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: isViewAnimated)
    }
    
    private func openChangeFontController(){
        let vc = ChangeFontViewController()
        vc.delegate = self
        vc.dataReceive = { [weak self] _ in
            self?.setupView()
            self?.tableView.reloadData()
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        nav.sheetPresentationController?.detents = [.large()]
        nav.sheetPresentationController?.prefersGrabberVisible = true
        nav.modalTransitionStyle = .coverVertical
        nav.isNavigationBarHidden = false
        self.present(nav, animated: isViewAnimated)
    }
    
    
    
}
//MARK: - Check Success Delegate
extension UserProfileViewController: CheckSuccessSaveProtocol, ChangeFontDelegate {
    func changeFont(font size: CGFloat, style: String) {
        restartApp()
        tableView.reloadData()
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
    //header and footer setups
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0...3: return cellArray[section].count
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UserProfileHeaderView()
        view.setupText(indexPath: section)
        return view 
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UserProfileFooterView()
        view.setupTextLabel(section: section)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0...2: return fontSizeValue * 3
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0...2: return fontSizeValue * 4
        default: return 0
        }
    }
    
    //cell setups
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileTableViewCell.identifier,for: indexPath) as! UserProfileTableViewCell
        let data = cellArray[indexPath.section][indexPath.row]
        cell.configureCell(text: data.title, imageCell: data.cellImage, image: data.cellImageColor)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        cell.configureSwitch(indexPath: indexPath)
        if indexPath == [1,0] {
            let appIcon = UIApplication.shared.alternateIconName ?? "AppIcon.png"
            let iconImage = UIImage(named: appIcon)?.withRenderingMode(.alwaysOriginal)
            let image = imageWith(image: iconImage!)
            cell.cellImageView.image = image
            cell.cellImageView.contentMode = .scaleAspectFit
        }
        
        switch indexPath {
        case [0,0]:
            cell.switchButton.isOn = userInterface.checkDarkModeUserDefaults() ?? setupSwitchDarkMode()
            cell.switchButton.addTarget(self, action: #selector(didTapSwitchDisplayMode), for: .valueChanged)
        case [0,1]:
            cell.switchButton.addTarget(self, action: #selector(didTapChangeAccessNotifications), for: .touchUpInside)
            showNotificationAccessStatus { access in
                DispatchQueue.main.async {
                    cell.switchButton.isOn = access
                }
            }
        case [0,2]:
            cell.switchButton.addTarget(self, action: #selector(didTapChangeAccessCalendar), for: .touchUpInside)
            request(forAllowing: eventStore) { access in
                DispatchQueue.main.async {
                    cell.switchButton.isOn = access
                }
            }
        case [0,3]:
            cell.switchButton.addTarget(self, action: #selector(didTapChangeAccessToContacts), for: .touchUpInside)
            checkAuthForContacts { success in
                DispatchQueue.main.async {
                    cell.switchButton.isOn = success
                }
            }
        case [0,4]:
            cell.switchButton.addTarget(self, action: #selector(didTapChangeAccessToMedia), for: .touchUpInside)
            checkAccessForMedia { success in
                DispatchQueue.main.async {
                    cell.switchButton.isOn = success
                }
            }
        case [0,5]:
            cell.switchButton.addTarget(self, action: #selector(didTapChangeAccessToFaceID), for: .touchUpInside)
            let value = UserDefaults.standard.bool(forKey: "accessToFaceID")
            if !value {
                checkAuthForFaceID { success in
                    DispatchQueue.main.async {
                        cell.switchButton.isOn = success
                    }
                }
            } else {
                cell.switchButton.isOn = value
            }
            
        case [1,2]:
            cell.switchButton.removeTarget(self, action: #selector(didTapSwitchDisplayMode), for: .valueChanged)
            cell.switchButton.addTarget(self, action: #selector(didTapDisableAnimation), for: .valueChanged)
            cell.switchButton.isOn = UserDefaults.standard.bool(forKey: "enabledAnimation")
        case [1,3]:
            cell.switchButton.removeTarget(self, action: #selector(didTapSwitchDisplayMode), for: .valueChanged)
            cell.switchButton.addTarget(self, action: #selector(didTapChangeNapticStyle), for: .valueChanged)
            cell.switchButton.isOn = UserDefaults.standard.bool(forKey: "enableVibration")

        default:
            break
        }
    
        cell.layer.cornerRadius = 12
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setupHapticMotion(style: .soft)
        tableView.deselectRow(at: indexPath, animated: isViewAnimated)
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
//            showSettingsForChangingAccess(title: "Changing App Language".localized(),
//                                          message: "Would you like to change the language of your application?".localized()) { _ in }
            showVariationsWithLanguage(title: "Change language", message: "") {  result in  }
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
        picker.dismiss(animated: isViewAnimated)
        activityIndicator.stopAnimating()
        view.alpha = 1
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: isViewAnimated)
        view.alpha = 1
        
    }
}

extension UserProfileViewController  {
    private func configureConstraints(){

        let infoStack = UIStackView(arrangedSubviews: [userNameLabel,mailLabel,ageLabel])
        infoStack.alignment = .fill
        infoStack.contentMode = .scaleAspectFit
        infoStack.axis = .vertical
        infoStack.spacing = 10
        
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
            self.userImageView.layer.cornerRadius = 55
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
            make.height.equalTo(100)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        
    }
}

