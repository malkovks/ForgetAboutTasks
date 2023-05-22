//
//  EditEventScheduleVC.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 20.05.2023.
//

import UIKit
import RealmSwift
import SnapKit
import Combine

class EditEventScheduleViewController: UIViewController {
    let headerArray = ["Details of event","Date and time","Category of event","Color of event","Repeat"]
    
    var cellsName = [[""],
                     ["","Set a reminder"],
                     ["","","",""],
                     [""],
                     ["Repeat every 7 days"]]
    
    private var cellBackgroundColor: UIColor
    private var choosenDate: Date
    private var scheduleModel: ScheduleModel
    
    init(cellBackgroundColor: UIColor, choosenDate: Date, scheduleModel: ScheduleModel){
        self.cellBackgroundColor = cellBackgroundColor
        self.choosenDate = choosenDate
        self.scheduleModel = scheduleModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var reminderStatus: Bool = false
    private var isStartEditing: Bool = false
    
    private var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    
   
    var editedScheduleModel = ScheduleModel()
    private let realm = try! Realm()
    
    private lazy var navigationItemButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapEdit))
    }()
    private let picker = UIColorPickerViewController()
    private let tableView = UITableView(frame: CGRectZero, style: .insetGrouped)
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showAlertForUser(text: "Saved successfully", duration: DispatchTime.now()+3, controllerView: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    //MARK: - Targets methods
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    @objc private func didTapSwitch(sender: UISwitch){
        if sender.isOn {
            scheduleModel.scheduleRepeat = true
        } else {
            scheduleModel.scheduleRepeat = false
        }
    }
    
    @objc private func didTapEdit(){
        let color = cellBackgroundColor.encode()
        editedScheduleModel.scheduleColor = color
        let filterDate = scheduleModel.scheduleDate ?? Date()
        let filterName = scheduleModel.scheduleName
        if !editedScheduleModel.scheduleName.isEmpty && editedScheduleModel.scheduleDate != nil && editedScheduleModel.scheduleTime != nil  {
            ScheduleRealmManager.shared.editScheduleModel(filterDate: filterDate, filterName: filterName, changes: editedScheduleModel)
            showAlertForUser(text: "Event edited successfully", duration: DispatchTime.now()+2, controllerView: view)
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                self.view.window?.rootViewController?.dismiss(animated: true)
            }
        } else {
            alertError()
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

    
    //MARK: - Setup Views and secondary methods
    private func setupView() {
        setupNavigationController()
        setupDelegate()
        setupColorPicker()
        setupTableView()
        view.backgroundColor = UIColor(named: "backgroundColor")
        title = "Editing event"
        
    }
    
    private func setupDelegate(){
        picker.delegate = self
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
        navigationItem.rightBarButtonItem = navigationItemButton
        navigationItemButton.isEnabled = false

    }
    //MARK: - Main functions for view
    private func setupUserNotification(model: ScheduleModel){
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        let dateS = model.scheduleTime ?? Date()
        let date = DateFormatter.localizedString(from: dateS, dateStyle: .medium, timeStyle: .none)
        let type = String(describing: model.scheduleCategoryType)
        let note = String(describing: model.scheduleCategoryNote)
        let nameCategory = String(describing: model.scheduleCategoryName)
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
    
    private func setupCellTitle(model: ScheduleModel,indexPath: IndexPath){
        let dateTime = model.scheduleTime ?? Date()
        switch indexPath {
        case [0,0]: cellsName[indexPath.section][indexPath.row] = model.scheduleName
        case [1,0]: cellsName[indexPath.section][indexPath.row] = DateFormatter.localizedString(from: dateTime, dateStyle: .medium, timeStyle: .short)
        case [2,0]: cellsName[indexPath.section][indexPath.row] = model.scheduleCategoryName ?? "Empty cell"
        case [2,1]: cellsName[indexPath.section][indexPath.row] = model.scheduleCategoryType ?? "Empty cell"
        case [2,2]: cellsName[indexPath.section][indexPath.row] = model.scheduleCategoryURL ?? "Empty cell"
        case [2,3]: cellsName[indexPath.section][indexPath.row] = model.scheduleCategoryNote ?? "Empty cell"
        default:
            print("Error")
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
            }
        })
        self.present(picker, animated: true)
    }
}
//MARK: - Table view delegates
extension EditEventScheduleViewController: UITableViewDelegate, UITableViewDataSource {
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
        if !isStartEditing {
            setupCellTitle(model: scheduleModel, indexPath: indexPath)
        }
        let data = cellsName[indexPath.section][indexPath.row]
        
        let convertedDate = DateFormatter.localizedString(from: scheduleModel.scheduleTime ?? Date(), dateStyle: .medium, timeStyle: .medium)
        
        cell.textLabel?.numberOfLines = 0
        cell.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(named: "cellColor")
        
        let switchButton = UISwitch(frame: .zero)
        switchButton.isOn = false
        switchButton.isHidden = true
        switchButton.onTintColor = cellBackgroundColor
        cell.accessoryView = switchButton
        
        cell.textLabel?.text = data
        if indexPath == [3,0] {
            cell.backgroundColor = cellBackgroundColor
        } else if indexPath == [1,1] {
            cell.accessoryView?.isHidden = false
            switchButton.addTarget(self, action: #selector(didTapSetReminder), for: .touchUpInside)
            let content = UNMutableNotificationContent()
            if content.userInfo["userNotification"] as? String == convertedDate {
                switchButton.isOn = true
            }
        } else if indexPath == [4,0] {
            cell.accessoryView?.isHidden = false
            switchButton.addTarget(self, action: #selector(didTapSwitch), for: .touchUpInside)
        } else {
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellName = cellsName[indexPath.section][indexPath.row]
        isStartEditing = true
        navigationItemButton.isEnabled = true
            switch indexPath {
            case [0,0]:
                alertTextField(cell: cellName, placeholder: "Enter text", keyboard: .default, table: tableView) {[self] text in
                    editedScheduleModel.scheduleName = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [1,0]:
                alertTimeInline(table: tableView, choosenDate: choosenDate) { [self] date, timeString, weekday in
                    editedScheduleModel.scheduleTime = date
                    editedScheduleModel.scheduleDate = date
                    editedScheduleModel.scheduleWeekday = weekday
//                    cellsName[indexPath.section][indexPath.row] = timeString
                }
            case [2,0]:
                alertTextField(cell: "Enter Name of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                    editedScheduleModel.scheduleCategoryName = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [2,1]:
                alertTextField(cell: "Enter Type of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                    editedScheduleModel.scheduleCategoryType = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [2,2]:
                alertTextField(cell: "Enter URL name with domain", placeholder: "Enter URL", keyboard: .emailAddress,table: tableView) { [self] text in
                    if (text.contains("www.") || text.contains("http://")) && text.contains(".") {
                        cellsName[indexPath.section][indexPath.row] = text
                        editedScheduleModel.scheduleCategoryURL = text
                    } else if !text.contains("www.") || !text.contains("http://") && text.contains("."){
                        let editedText = "www." + text
                        cellsName[indexPath.section][indexPath.row] = editedText
                        editedScheduleModel.scheduleCategoryURL = text
                    } else {
                        alertError(text: "Enter name of URL link with correct domain", mainTitle: "Incorrect input")
                    }
                }
            case [2,3]:
                alertTextField(cell: "Enter Notes of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                    editedScheduleModel.scheduleCategoryNote = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [3,0]:
                openColorPicker()
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
        if indexPath == [2,3] {
            return UITableView.automaticDimension
        }
        return 45
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
}
//MARK: - Color picker delegate
extension EditEventScheduleViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        cellBackgroundColor = color
        self.tableView.reloadData()
    }
}


