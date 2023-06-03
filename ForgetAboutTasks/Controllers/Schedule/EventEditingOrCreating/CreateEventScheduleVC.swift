//
//  CreateEventScheduleViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 17.03.2023.
//

import UIKit
import SnapKit
import Combine
import UserNotifications
import RealmSwift

class CreateEventScheduleViewController: UIViewController {
    
    weak var delegate: CheckSuccessSaveProtocol?
    
    private let headerArray = ["Details of event","Date and time","Category of event","Color of event","Image"]
    
    private var cellsName = [["Name of event"],
                     ["Date and Time","Set a reminder"],
                     ["Name","Type","URL","Note"],
                     [""],
                     ["Choose photo"]]
    
    private var reminderStatus: Bool = false
    private var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    private var scheduleModel = ScheduleModel()
    private let realm = try! Realm()
    private var cellBackgroundColor =  #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    private var choosenDate: Date
    private var isStartEditing: Bool = false
    private var cellImageView: UIImageView?
    
    init(choosenDate: Date){
        self.choosenDate = choosenDate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let picker = UIColorPickerViewController()
    private let tableView = UITableView(frame: CGRectZero, style: .insetGrouped)
    private var imagePicker = UIImagePickerController()
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
    }

    //MARK: - Targets methods
    @objc private func didTapDismiss(){
        if isStartEditing {
            setupAlertSheet(title:"Attention", subtitle: "You inputed the data that was not saved.\nWhat do you want to do?" )
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func didTapSave(){
        scheduleModel.scheduleColor = cellBackgroundColor.encode()
        
        let isClear = setupAlertIfDataEmpty()
        if isClear {
            if reminderStatus {
                setupUserNotification(model: scheduleModel)
                delegate?.isSavedCompletely(boolean: true)
                reminderStatus = false
            }
            ScheduleRealmManager.shared.saveScheduleModel(model: scheduleModel)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc private func didTapSwitch(sender: UISwitch){
        if sender.isOn {
            scheduleModel.scheduleRepeat = true
        } else {
            scheduleModel.scheduleRepeat = false
        }
    }
    
    @objc private func didTapSetReminder(sender: UISwitch){
        if sender.isOn {
            if scheduleModel.scheduleDate == nil && scheduleModel.scheduleTime == nil {
                alertError(text: "Enter date for setting reminder", mainTitle: "Error set up reminder!")
            } else {
                reminderStatus = true
            }
        } else {
            reminderStatus = false
        }
    }

    @objc private func didTapChangeCell(_ tag: AnyObject) {
        let button = tag as! UIButton
        let _ = IndexPath(row: button.tag, section: 4)
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
            self.cellImageView?.image = UIImage(systemName: "photo.circle")
            self.cellImageView?.sizeToFit()
//            UserDefaults.standard.set(nil,forKey: "userImage")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)

        
    }
    //MARK: - Setup Views and secondary methods
    private func setupAlertSheet(title: String,subtitle: String) {
        let sheet = UIAlertController(title: title, message: subtitle, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Discard changes", style: .destructive,handler: { _ in
            self.dismiss(animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Save", style: .default,handler: { [self] _ in
            didTapSave()
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    
    private func setupView() {
        setupNavigationController()
        setupDelegate()
        setupColorPicker()
        setupConstraints()
        
        view.backgroundColor = UIColor(named: "backgroundColor")
        title = "Options"
        
    }
    
    private func setupDelegate(){
        picker.delegate = self
        imagePicker.delegate = self
    }
    
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupColorPicker(){
        picker.selectedColor = self.view.backgroundColor ?? #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    }

    
    private func setupNavigationController(){
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        navigationItem.rightBarButtonItems = [saveButton]
    }
    
    private func setupUserNotification(model: ScheduleModel){
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        let dateS = model.scheduleTime ?? Date()
        print(dateS)
        let date = DateFormatter.localizedString(from: dateS, dateStyle: .medium, timeStyle: .none)
        content.title = "Planned reminder"
        content.body = "\(date)"
        content.subtitle = "\(model.scheduleName)"
        content.sound = .defaultRingtone
        let dateFormat = DateFormatter.localizedString(from: scheduleModel.scheduleDate ?? Date(), dateStyle: .medium, timeStyle:.none)
        content.userInfo = ["userNotification": dateFormat]
        let components = Calendar.current.dateComponents([.day,.month,.year,.hour,.minute,.second], from: dateS)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "request", content: content, trigger: trigger)
        center.add(request) { [weak self] error in
            if error != nil {
                self?.alertError()
            }
        }
    }
    //MARK: - Logics methods
    
    private func setupAlertIfDataEmpty() -> Bool{
        if scheduleModel.scheduleName == "Unknown" {
            alertError(text: "Enter value in Name cell")
            return false
        } else if scheduleModel.scheduleDate == nil {
            alertError(text: "Choose date of event")
            return false
        } else if scheduleModel.scheduleTime == nil {
            alertError(text: "Choose time of event")
            return false
        } else {
            return true
        }
    }

    //MARK: - Segue methods
    //methods with dispatch of displaying color in cell while choosing color in picker view
    @objc private func openColorPicker(){
        self.cancellable = picker.publisher(for: \.selectedColor) .sink(receiveValue: { color in
            DispatchQueue.main.async {
                self.cellBackgroundColor = color
                self.isStartEditing = true
            }
        })
        self.present(picker, animated: true)
    }
}
extension CreateEventScheduleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            guard let data = image.jpegData(compressionQuality: 1.0) else { return}
            let _ = try! PropertyListEncoder().encode(data)
            cellImageView?.image = image
            guard let index = tableView.indexPathForSelectedRow,
                  let cell = tableView.cellForRow(at: index) else { alertError();return }
            
            cell.imageView?.image = image
            cell.textLabel?.text = ""
            cell.imageView?.frame = CGRect(x: 1, y: 1, width: tableView.frame.size.width-2, height: 200)
            cell.accessoryView = nil
            
            cellImageView?.image = image
            picker.dismiss(animated: true)
            tableView.deselectRow(at: index, animated: true)
//            UserDefaults.standard.setValue(encode, forKey: "userImage")
//            userImageView.image = image
        } else {
            alertError(text: "Error!", mainTitle: "Can't get image and save it to event.\nTry again later!")
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}

//MARK: - Table view delegates
extension CreateEventScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 4
        case 3: return 1
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let data = cellsName[indexPath.section][indexPath.row]
        
        cell.textLabel?.numberOfLines = 0
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(named: "cellColor")
        cell.textLabel?.text = data
        
        let switchButton = UISwitch(frame: .zero)
        switchButton.isOn = false
        switchButton.isHidden = true
        switchButton.onTintColor = cellBackgroundColor
        switchButton.addTarget(self, action: #selector(didTapSetReminder), for: .touchUpInside)
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 41, height: 41)
        button.tintColor = UIColor(named: "navigationControllerColor")
        button.addTarget(self, action: #selector(didTapChangeCell), for: .touchUpInside)
        button.sizeToFit()
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.tintColor = UIColor(named: "navigationControllerColor")
        button.tag = indexPath.row
    
        if indexPath == [3,0] {
            cell.backgroundColor = cellBackgroundColor
        } else if indexPath == [1,1] {
            cell.accessoryView = switchButton
            cell.accessoryView?.isHidden = false
        } else if indexPath == [4,0] {
            if cellImageView == nil {
                cell.accessoryView = button
            }
        } else {
            cell.accessoryView?.isHidden = true
            cell.accessoryView = nil
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        let cellName = cellsName[indexPath.section][indexPath.row]
        
        switch indexPath {
        case [0,0]:
            alertTextField(cell: cellName, placeholder: "Enter text", keyboard: .default, table: tableView) {[self] text in
                scheduleModel.scheduleName = text
                cell?.textLabel?.text = text
//                cellsName[indexPath.section][indexPath.row] = text
                isStartEditing = true
            }
        case [1,0]:
            alertTimeInline(table: tableView, choosenDate: choosenDate) { [self] date, timeString, weekday in
                scheduleModel.scheduleTime = date
                scheduleModel.scheduleDate = date
                scheduleModel.scheduleWeekday = weekday
                cell?.textLabel?.text = timeString
                isStartEditing = true
            }
        case [2,0]:
            alertTextField(cell: "Enter Name of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                scheduleModel.scheduleCategoryName = text
                cell?.textLabel?.text = text
                isStartEditing = true
            }
        case [2,1]:
            alertTextField(cell: "Enter Type of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                scheduleModel.scheduleCategoryType = text
                cell?.textLabel?.text = text
                isStartEditing = true
            }
        case [2,2]:
            alertTextField(cell: "Enter URL name with domain", placeholder: "Enter URL", keyboard: .URL,table: tableView) { [self] text in
                if text.isURLValid(text: text) {
                    cell?.textLabel?.text = text
                    scheduleModel.scheduleCategoryURL = text
                    isStartEditing = true
                } else if !text.contains("www.") || !text.contains("http://") && text.contains("."){
                    let editedText = "www." + text
                    cell?.textLabel?.text = editedText
                    scheduleModel.scheduleCategoryURL = editedText
                    isStartEditing = true
                } else {
                    alertError(text: "Enter name of URL link with correct domain", mainTitle: "Incorrect input")
                }
            }
        case [2,3]:
            alertTextField(cell: "Enter Notes of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                cell?.textLabel?.text = text
                cellsName[indexPath.section][indexPath.row] = text
                isStartEditing = true
            }
        case [3,0]:
            openColorPicker()
        case [4,0]:
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(self.imagePicker, animated: true)
            
        default:
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerArray[section]
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == [2,3] && indexPath == [4,0]{
            return UITableView.automaticDimension
        }
        return 45
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
}
//MARK: - Color picker delegate
extension CreateEventScheduleViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        cellBackgroundColor = color
        let cell = tableView.cellForRow(at: [3,0])
        cell?.backgroundColor = cellBackgroundColor
        let encodeColor = color.encode()
        DispatchQueue.main.async {
            self.scheduleModel.scheduleColor = encodeColor
            try! self.realm.write {
                self.scheduleModel.scheduleColor = encodeColor
            }
//            self.tableView.reloadData()
        }
    }
}
//MARK: - Setup constraint extension

extension CreateEventScheduleViewController {
    private func setupConstraints(){
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(0)
        }
    }
    
}
