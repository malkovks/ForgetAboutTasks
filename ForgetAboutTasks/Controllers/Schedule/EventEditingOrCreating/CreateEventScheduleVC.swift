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
    
    private let headerArray = ["Details of event","Date and time","Category of event","Color of event","Repeat"]
    
    private var cellsName = [["Name of event"],
                     ["Date and Time","Set a reminder"],
                     ["Name","Type","URL","Note"],
                     [""],
                     ["Repeat every 7 days"]]
    
    private var reminderStatus: Bool = false
    private var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    private var scheduleModel = ScheduleModel()
    private let realm = try! Realm()
    private var cellBackgroundColor =  #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    private var choosenDate: Date
    private var isStartEditing: Bool = false
    
    init(choosenDate: Date){
        self.choosenDate = choosenDate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let picker = UIColorPickerViewController()
    private let tableView = UITableView(frame: CGRectZero, style: .insetGrouped)
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showAlertForUser(text: "Saved successfully", duration: DispatchTime.now()+1, controllerView: view)
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
                reminderStatus = false
            }
            ScheduleRealmManager.shared.saveScheduleModel(model: scheduleModel)
            alertDismissed(view: view)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.view.window?.rootViewController?.dismiss(animated: true)
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
        
        switch indexPath {
        case [0,0]:
            alertTextField(cell: cellName, placeholder: "Enter text", keyboard: .default, table: tableView) {[self] text in
                scheduleModel.scheduleName = text
                cellsName[indexPath.section][indexPath.row] = text
                isStartEditing = true
            }
        case [1,0]:
            alertTimeInline(table: tableView, choosenDate: choosenDate) { [self] date, timeString, weekday in
                scheduleModel.scheduleTime = date
                scheduleModel.scheduleDate = date
                scheduleModel.scheduleWeekday = weekday
                cellsName[indexPath.section][indexPath.row] = timeString
                isStartEditing = true
            }
        case [2,0]:
            alertTextField(cell: "Enter Name of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                scheduleModel.scheduleCategoryName = text
                cellsName[indexPath.section][indexPath.row] = text
                isStartEditing = true
            }
        case [2,1]:
            alertTextField(cell: "Enter Type of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                scheduleModel.scheduleCategoryType = text
                cellsName[indexPath.section][indexPath.row] = text
                isStartEditing = true
            }
        case [2,2]:
            alertTextField(cell: "Enter URL name with domain", placeholder: "Enter URL", keyboard: .emailAddress,table: tableView) { [self] text in
                if (text.contains("www.") || text.contains("https://")) && text.contains(".") {
                    cellsName[indexPath.section][indexPath.row] = text
                    scheduleModel.scheduleCategoryURL = text
                    isStartEditing = true
                } else if !text.contains("www.") || !text.contains("http://") && text.contains("."){
                    let editedText = "www." + text
                    cellsName[indexPath.section][indexPath.row] = editedText
                    scheduleModel.scheduleCategoryURL = text
                    isStartEditing = true
                } else {
                    alertError(text: "Enter name of URL link with correct domain", mainTitle: "Incorrect input")
                }
            }
        case [2,3]:
            alertTextField(cell: "Enter Notes of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                scheduleModel.scheduleCategoryNote = text
                cellsName[indexPath.section][indexPath.row] = text
                isStartEditing = true
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
extension CreateEventScheduleViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        cellBackgroundColor = color
        let encodeColor = color.encode()
        DispatchQueue.main.async {
            self.scheduleModel.scheduleColor = encodeColor
            try! self.realm.write {
                self.scheduleModel.scheduleColor = encodeColor
            }
            self.tableView.reloadData()
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
