//
//  OptionsForScheduleViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 17.03.2023.
//

import UIKit
import SnapKit
import Combine
import UserNotifications
import RealmSwift

class OptionsForScheduleViewController: UIViewController {
    
    let headerArray = ["Details of event","Date and time","Category of event","Color of event","Repeat"]
    
    var cellsName = [["Name of event"],
                     ["Date and Time","Set a reminder"],
                     ["Name","Type","URL","Note"],
                     [""],
                     ["Repeat every 7 days"]]
    
    var cellBackgroundColor =  #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    var isEditingView: Bool = false
    var choosenDate = Date()
    private var reminderStatus: Bool = false
    
    private var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    
    private let picker = UIColorPickerViewController()
    var scheduleModel = ScheduleModel()
    var editedScheduleModel = ScheduleModel()
    private lazy var navigationItemButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
    }()
    
    private let tableView = UITableView(frame: CGRectZero, style: .insetGrouped)
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
    }

    //MARK: - Targets methods
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    @objc private func didTapSave(){
        scheduleModel.scheduleColor = cellBackgroundColor.encode()
        
        let isClear = setupAlertIfDataEmpty()
        if isClear {
            ScheduleRealmManager.shared.saveScheduleModel(model: scheduleModel)
            if reminderStatus {
                setupUserNotification(model: scheduleModel)
                reminderStatus = false
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
    
    @objc private func didTapEdit(){
        let color = cellBackgroundColor.encode()
        editedScheduleModel.scheduleColor = color
        let filterDate = scheduleModel.scheduleDate ?? Date()
        let filterName = scheduleModel.scheduleName
        if !editedScheduleModel.scheduleName.isEmpty && editedScheduleModel.scheduleDate != nil && editedScheduleModel.scheduleTime != nil  {
            ScheduleRealmManager.shared.editScheduleModel(filterDate: filterDate, filterName: filterName, changes: editedScheduleModel)
            self.view.window?.rootViewController?.dismiss(animated: true)
//            let vc = ScheduleViewController()
//            alertDismissed(view: vc.view)
            print("Edited completely")
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
        if isEditingView {
            navigationItem.rightBarButtonItem = navigationItemButton
            navigationItemButton.isEnabled = false
        } else {
            navigationItem.rightBarButtonItems = [saveButton]
        }
    }
    
    private func setupUserNotification(model: ScheduleModel){
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        let date = model.scheduleTime ?? Date()
        let type = String(describing: model.scheduleCategoryType)
        let note = String(describing: model.scheduleCategoryNote)
        let nameCategory = String(describing: model.scheduleCategoryName)
        content.title = "Planned reminder to you on \(date)"
        content.body = "\(model.scheduleName)"
        content.subtitle = ".\(nameCategory), \(type), \(note)"
        content.sound = .defaultRingtone
        let dateFormat = DateFormatter.localizedString(from: scheduleModel.scheduleDate ?? Date(), dateStyle: .medium, timeStyle:.none)
        content.userInfo = ["userNotification": dateFormat]
        let components = Calendar.current.dateComponents([.day,.month,.year,.hour,.minute,.second], from: date)
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
            }
        })
        self.present(picker, animated: true)
    }
}

extension OptionsForScheduleViewController: UITableViewDelegate, UITableViewDataSource {
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
        
        let dateAndTime = scheduleModel.scheduleTime ?? Date()
        
        cell.textLabel?.numberOfLines = 0
        cell.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(named: "cellColor")
        
        let switchButton = UISwitch(frame: .zero)
        switchButton.isOn = false
        switchButton.isHidden = true
        switchButton.onTintColor = cellBackgroundColor
        cell.accessoryView = switchButton
        
        if isEditingView {
            switch indexPath {
            case [0,0]:
                cell.textLabel?.text = scheduleModel.scheduleName
                cell.accessoryView = nil
            case [1,0]:
                let time = DateFormatter.localizedString(from: dateAndTime, dateStyle: .medium, timeStyle: .short)
                cell.textLabel?.text = time
                cell.accessoryView = nil
            case [1,1]:
                cell.textLabel?.text = data
                cell.accessoryView?.isHidden = false
                switchButton.isOn = false
            case[2,0]:
                cell.textLabel?.text = scheduleModel.scheduleCategoryName ?? data
                cell.accessoryView = nil
            case [2,1]:
                cell.textLabel?.text = scheduleModel.scheduleCategoryType ?? data
                cell.accessoryView = nil
            case [2,2]:
                cell.textLabel?.text = scheduleModel.scheduleCategoryURL ?? data
                cell.accessoryView = nil
            case [2,3]:
                cell.textLabel?.text = scheduleModel.scheduleCategoryNote ?? data
                cell.accessoryView = nil
            case [3,0]:
                cell.backgroundColor = UIColor.color(withData: (scheduleModel.scheduleColor)!)
            case [4,0]:
                cell.textLabel?.text = data
                cell.accessoryView?.isHidden = false
                switchButton.isOn = scheduleModel.scheduleRepeat ?? false
            default:
                alertError(text: "Please,try again later\nError getting data", mainTitle: "Error!!")
            }
        } else {
            
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellName = cellsName[indexPath.section][indexPath.row]

        if isEditingView {
          switch indexPath {
            case [0,0]:
                alertTextField(cell: cellName, placeholder: "Enter text", keyboard: .default, table: tableView) {[self] text in
                    editedScheduleModel.scheduleName = text
                    cellsName[indexPath.section][indexPath.row] = text
                    navigationItemButton.isEnabled = true
                }
            case [1,0]:
                alertTimeInline(table: tableView, choosenDate: choosenDate) { [self] date, timeString, weekday in
                    editedScheduleModel.scheduleTime = date
                    editedScheduleModel.scheduleDate = date
                    editedScheduleModel.scheduleWeekday = weekday
                    cellsName[indexPath.section][indexPath.row] = timeString
                    navigationItemButton.isEnabled = true
                }
            case [2,0]:
                alertTextField(cell: "Enter Name of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                    editedScheduleModel.scheduleCategoryName = text
                    cellsName[indexPath.section][indexPath.row] = text
                    navigationItemButton.isEnabled = true
                }
            case [2,1]:
                alertTextField(cell: "Enter Type of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                    editedScheduleModel.scheduleCategoryType = text
                    cellsName[indexPath.section][indexPath.row] = text
                    navigationItemButton.isEnabled = true
                }
            case [2,2]:
                alertTextField(cell: "Enter URL of event", placeholder: "Enter the text", keyboard: .emailAddress,table: tableView) { [self] text in
                    editedScheduleModel.scheduleCategoryURL = text
                    cellsName[indexPath.section][indexPath.row] = text
                    navigationItemButton.isEnabled = true
                }
            case [2,3]:
                alertTextField(cell: "Enter Notes of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                    if (text.contains("www.") || text.contains("https://")) && text.contains(".") {
                        cellsName[indexPath.section][indexPath.row] = text
                        editedScheduleModel.scheduleCategoryURL = text
                        navigationItemButton.isEnabled = true
                    } else {
                        alertError(text: "Try again!\nEnter www. in URL link and pick a domain", mainTitle: "Warning!")
                    }
                }
            case [3,0]:
                openColorPicker()
                navigationItemButton.isEnabled = true
                
                            
            default:
                print("error")
            }
        } else {
            scheduleModel.scheduleRepeat = false
            switch indexPath {
            case [0,0]:
                alertTextField(cell: cellName, placeholder: "Enter text", keyboard: .default, table: tableView) {[self] text in
                    scheduleModel.scheduleName = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [1,0]:
                alertTimeInline(table: tableView, choosenDate: choosenDate) { [self] date, timeString, weekday in
                    scheduleModel.scheduleTime = date
                    scheduleModel.scheduleDate = date
                    scheduleModel.scheduleWeekday = weekday
                    cellsName[indexPath.section][indexPath.row] = timeString
                }
            case [2,0]:
                alertTextField(cell: "Enter Name of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                    scheduleModel.scheduleCategoryName = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [2,1]:
                alertTextField(cell: "Enter Type of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                    scheduleModel.scheduleCategoryType = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [2,2]:
                alertTextField(cell: "Enter URL of event", placeholder: "Enter the text", keyboard: .emailAddress,table: tableView) { [self] text in
                    if (text.contains("www.") || text.contains("https://")) && text.contains(".") {
                        cellsName[indexPath.section][indexPath.row] = text
                        scheduleModel.scheduleCategoryURL = text
                    } else {
                        alertError(text: "Try again!\nEnter www. in URL link and pick a domain", mainTitle: "Warning!")
                    }
                }
            case [2,3]:
                alertTextField(cell: "Enter Notes of event", placeholder: "Enter the text", keyboard: .default,table: tableView) { [self] text in
                    scheduleModel.scheduleCategoryNote = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [3,0]:
                openColorPicker()
            default:
                print("error")
            }
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
extension OptionsForScheduleViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        cellBackgroundColor = color
        let encodeColor = color.encode()
        if !isEditingView {
            DispatchQueue.main.async {
                self.scheduleModel.scheduleColor = encodeColor
                self.tableView.reloadData()
            }
        }
        
    }
}
//MARK: - Adaptivity PC delegate and constraints setups

extension OptionsForScheduleViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {    }
}

extension OptionsForScheduleViewController {
    private func setupConstraints(){
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(0)
        }
    }
}
