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
import EventKit
import Photos
import AVFoundation


class CreateEventScheduleViewController: UIViewController {
    
    weak var delegate: CheckSuccessSaveProtocol?
    
    private let headerArray = ["Details of event".localized(),
                               "Start and End of event".localized(),
                               "Category of event".localized(),
                               "Color of event".localized(),
                               "Choose image".localized()]
    
    private var cellsName = [["Name of event".localized()],
                     ["Start".localized()
                      ,"End".localized()
                      ,"Set a reminder".localized()
                      ,"Add to Calendar".localized()],
                     ["Name".localized()
                      ,"Type".localized()
                      ,"URL".localized()
                      ,"Note".localized()],
                     [""],
                     [""]]
    
    
    private var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    private let notificationCenter = UNUserNotificationCenter.current()
    private let eventStore = EKEventStore()
    private let library = PHPhotoLibrary.self
    private let camera = AVCaptureDevice.self
    private var scheduleModel = ScheduleModel()
    private let realm = try! Realm()
    private var cellBackgroundColor: UIColor =  #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    private var isStartEditing: Bool = false
    private var reminderStatus: Bool = false
    private var addingEventStatus: Bool = false
    private var choosenDate: Date
    private lazy var startChoosenDate: Date = choosenDate
    private let fontSizeValue : CGFloat = CGFloat(UserDefaults.standard.float(forKey: "fontSizeChanging"))

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
    private let indicator = UIActivityIndicatorView(style: .medium)
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
        
        let isClear = setupAlertIfDataEmpty()
        if isClear {
            scheduleModel.scheduleColor = cellBackgroundColor.encode()
            setupUserNotification(model: scheduleModel, status: reminderStatus)
            setupCalendarEvent(model: scheduleModel, status: addingEventStatus)
            delegate?.isSavedCompletely(boolean: true)
            ScheduleRealmManager.shared.saveScheduleModel(model: self.scheduleModel)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc private func didTapSetReminder(sender: UISwitch){
        if sender.isOn {
            if scheduleModel.scheduleStartDate == nil && scheduleModel.scheduleTime == nil {
                alertError(text: "Enter date for setting reminder".localized(), mainTitle: "Error set up reminder!".localized())
            } else {
                DispatchQueue.main.async {
                    self.request(forUser: self.notificationCenter) { access in
                        self.reminderStatus = access
                        self.scheduleModel.scheduleActiveNotification = access
                        sender.isOn = access
                    }
                }
            }
        } else {
            reminderStatus = false
            scheduleModel.scheduleActiveNotification = false
        }
    }
    
    @objc private func didTapSetEKEvent(sender: UISwitch){
        if sender.isOn {
            if scheduleModel.scheduleStartDate == nil && scheduleModel.scheduleEndDate == nil {
                alertError(text: "Enter date for adding event to Calendar", mainTitle: "Error!")
            } else {
                self.request(forAllowing: self.eventStore) { access in
                    self.addingEventStatus = access
                    self.scheduleModel.scheduleActiveCalendar = access
                    sender.isOn = access
                }
            }
        } else {
            addingEventStatus = false
            scheduleModel.scheduleActiveCalendar = false
        }
    }


    //MARK: - Setup Views and secondary methods
    private func setupAlertSheet(title: String,subtitle: String) {
        let sheet = UIAlertController(title: title, message: subtitle, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Discard changes".localized(), style: .destructive,handler: { _ in
            self.dismiss(animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Save".localized(), style: .default,handler: { [self] _ in
            didTapSave()
        }))
        sheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(sheet, animated: true)
    }

    
    private func setupView() {
        
        setupNavigationController()
        setupDelegate()
        setupColorPicker()
        setupConstraints()
        
        view.backgroundColor = UIColor(named: "backgroundColor")
        title = "Options".localized()
        
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
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.identifier)
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
    

    
    private func setupUserNotification(model: ScheduleModel,status: Bool){
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        let dateS = model.scheduleTime ?? Date()
        let date = DateFormatter.localizedString(from: dateS, dateStyle: .medium, timeStyle: .none)
        content.title = "Planned reminder".localized()
        content.body = "\(date)"
        content.subtitle = "\(String(describing:model.scheduleName))"
        content.sound = .defaultRingtone
        let dateFormat = DateFormatter.localizedString(from: scheduleModel.scheduleStartDate ?? Date(), dateStyle: .medium, timeStyle:.short)
        content.userInfo = ["userNotification": dateFormat]
        let components = Calendar.current.dateComponents([.day,.month,.year,.hour,.minute,.second], from: dateS)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "request", content: content, trigger: trigger)
        if status {
            center.add(request) { [weak self] error in
                if error != nil {
                    self?.alertError()
                }
            }
        }
        
    }
    

    
    private func setupCalendarEvent(model: ScheduleModel,status: Bool){
        let store = EKEventStore()
        if let calendar = store.defaultCalendarForNewEvents{
            if status {
                let event: EKEvent = EKEvent(eventStore: store)
                event.calendar = calendar
                event.startDate = model.scheduleStartDate
                event.endDate = model.scheduleEndDate
                event.title = model.scheduleName
                event.url = URL(string: model.scheduleCategoryURL ?? "")
                event.notes = model.scheduleCategoryNote
                let reminder = EKAlarm(absoluteDate: model.scheduleStartDate ?? Date())
                event.alarms = [reminder]
                do {
                    try store.save(event, span: .thisEvent)
                    scheduleModel.scheduleActiveCalendar = true
                } catch let error as NSError{
                    alertError(text: error.localizedDescription, mainTitle: "Error!")
                }
            }
        } else {
            alertError(text: "Error saving event to calendar")
        }
    }
    
    //MARK: - Logics methods
    
    private func setupAlertIfDataEmpty() -> Bool{
        if scheduleModel.scheduleName == "" {
            alertError(text: "Enter value in Name cell")
            return false
        } else if scheduleModel.scheduleStartDate == nil {
            alertError(text: "Choose date of event")
            return false
        } else if scheduleModel.scheduleEndDate == nil {
            alertError(text: "Choose time of event")
            return false
        } else if scheduleModel.scheduleStartDate?.compare(scheduleModel.scheduleEndDate ?? startChoosenDate) == .orderedDescending {
            alertError(text: "End Date can't end earlier than Start Date. Change start or end date", mainTitle: "Error")
            return false
        } else {
            return true
        }
    }
    
    @objc private func chooseTypeOfImagePicker() {
        
        let alert = UIAlertController(title: "", message: "What exactly do you want to do?".localized(), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Set new image".localized(), style: .default,handler: { [self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                present(self.imagePicker, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Make new image".localized(), style: .default,handler: { [self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                present(self.imagePicker, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Delete image".localized(), style: .destructive,handler: { _ in
            let cell = self.tableView.cellForRow(at: [4,0])
            cell?.imageView?.image = UIImage(named: "camera.fill")
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: true)
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
    
//    @objc private func openImagePicker(){
//        self.cancellable = imagePicker.publisher(for: \.sourceType)
//            .sink(receiveValue: { image in
//                DispatchQueue.main.async {
//                    self.cellImage = image
//                    self.isStartEditing = true
//                }
//            })
//        self.present(imagePicker, animated: true)
//    }
}
//MARK: - ImagePicker delegate
extension CreateEventScheduleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage{
            guard let data = image.jpegData(compressionQuality: 1.0) else { return}
            scheduleModel.scheduleImage = data
            tableView.reloadSections(NSIndexSet(index: 4) as IndexSet, with: .automatic)
            picker.dismiss(animated: true)
            tableView.deselectRow(at: [4,0], animated: true)
            
        } else {
            alertError(text: "Error!".localized(), mainTitle: "Can't get image and save it to event.\nTry again later!".localized())
        }
        indicator.stopAnimating()
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        tableView.deselectRow(at: [4,0], animated: true)
        picker.dismiss(animated: true)
    }
    
}

//MARK: - Table view delegates
extension CreateEventScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 4
        case 2: return 4
        case 3: return 1
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let customCell = (tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.identifier) as? ScheduleTableViewCell)!
        let data = cellsName[indexPath.section][indexPath.row]
        
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.font = .systemFont(ofSize: fontSizeValue)
        cell?.contentView.layer.cornerRadius = 10
        cell?.backgroundColor = UIColor(named: "cellColor")
        cell?.textLabel?.text = data
        
        let switchButton = UISwitch(frame: .zero)
        switchButton.isOn = false
        switchButton.isHidden = true
        switchButton.onTintColor = cellBackgroundColor
        
    
        if indexPath == [3,0] {
            cell?.backgroundColor = cellBackgroundColor
        } else if indexPath == [1,2] {
            cell?.accessoryView = switchButton
            cell?.accessoryView?.isHidden = false
            switchButton.addTarget(self, action: #selector(didTapSetReminder), for: .touchUpInside)
        } else if indexPath == [1,3] {
            cell?.accessoryView = switchButton
            cell?.accessoryView?.isHidden = false
            switchButton.addTarget(self, action: #selector(didTapSetEKEvent), for: .touchUpInside)
        } else if indexPath == [4,0] {
            let image = UIImage(data: scheduleModel.scheduleImage ?? Data())
            customCell.imageViewSchedule.image = image ?? UIImage(systemName: "camera.fill")
            return customCell
        } else {
            cell?.accessoryView?.isHidden = true
            cell?.accessoryView = nil
        }
            
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        let cellName = cellsName[indexPath.section][indexPath.row]
        
        switch indexPath {
        case [0,0]:
            alertTextField(cell: cellName, placeholder: "Enter the text".localized(), keyboard: .default) {[self] text in
                scheduleModel.scheduleName = text
                cell?.textLabel?.text = text
                isStartEditing = true
            }
        case [1,0]:
            alertTimeInline(table: tableView, choosenDate: choosenDate) { [self] date, timeString, weekday in
                scheduleModel.scheduleTime = date
                scheduleModel.scheduleStartDate = date
                scheduleModel.scheduleWeekday = weekday
                scheduleModel.scheduleEndDate = date.addingTimeInterval(3600)
                startChoosenDate = date.addingTimeInterval(3600)
                cell?.textLabel?.text = timeString
                isStartEditing = true
            }
        case [1,1]:
            let hourPlus = scheduleModel.scheduleStartDate
            let hour = hourPlus?.addingTimeInterval(3600) ?? startChoosenDate.addingTimeInterval(3600)
            alertTimeInline(table: tableView, choosenDate: hour) { [weak self] date, dateString, weekday in
                self?.scheduleModel.scheduleEndDate = date
                cell?.textLabel?.text = dateString
                self?.isStartEditing = true
            }
        case [2,0]:
            alertTextField(cell: "Enter Name of event".localized(), placeholder: "Enter the text".localized(), keyboard: .default) { [self] text in
                scheduleModel.scheduleCategoryName = text
                cell?.textLabel?.text = text
                isStartEditing = true
                
            }
        case [2,1]:
            alertTextField(cell: "Enter Type of event".localized(), placeholder: "Enter the text".localized(), keyboard: .default) { [self] text in
                scheduleModel.scheduleCategoryType = text
                cell?.textLabel?.text = text
                isStartEditing = true
                
            }
        case [2,2]:
            alertTextField(cell: "Enter URL name with domain".localized(), placeholder: "Enter URL".localized(), keyboard: .URL) { [self] text in
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
            alertTextField(cell: "Enter Notes of event".localized(), placeholder: "Enter the text".localized(), keyboard: .default) { [self] text in
                scheduleModel.scheduleCategoryNote = text
                cell?.textLabel?.text = text
                isStartEditing = true
            }
        case [3,0]:
            openColorPicker()
        case [4,0]:
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            requestForUserLibrary { status in }
            requestUserForCamera()
            chooseTypeOfImagePicker()
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
        } else if indexPath == [4,0] {
            return 300
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
