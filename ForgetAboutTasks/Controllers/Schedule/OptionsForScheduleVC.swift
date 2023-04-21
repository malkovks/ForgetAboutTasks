//
//  OptionsForScheduleViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 17.03.2023.
//

import UIKit
import SnapKit
import Combine

class OptionsForScheduleViewController: UIViewController {
    
    let headerArray = ["Details of event","Date and time","Category of event","Color of event","Repeat"]
    
    var cellsName = [["Name of event"],
                     ["Date", "Time"],
                     ["Name","Type","URL","Note"],
                     [""],
                     ["Repeat every 7 days"]]
    
    var cellBackgroundColor =  #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    var isEditingView: Bool = false
    
    private var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    
    private let picker = UIColorPickerViewController()
    private var scheduleModel = ScheduleModel()
    var testScheduleModel: ScheduleModel?
    
    private let tableView = UITableView()
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
        let isClear = setupAlertIfDataEmpty()
        if isClear {
            ScheduleRealmManager.shared.saveScheduleModel(model: scheduleModel)
            scheduleModel = ScheduleModel()
            self.dismiss(animated: true)
        }
    }
    
    @objc private func didTapSwitch(sender: UISwitch){
        if sender.isOn {
            print("It repeat")
            scheduleModel.scheduleRepeat = true
        } else {
            print("it doesnt repeat")
            scheduleModel.scheduleRepeat = false
        }
    }

    
    //MARK: - Setup Views and secondary methods
    private func setupView() {
        setupNavigationController()
        setupDelegate()
        setupColorPicker()
        setupConstraints()
        basedValueForModel()
        view.backgroundColor = .secondarySystemBackground
        title = "Options"
        
    }
    
    private func setupDelegate(){
        picker.delegate = self
    }
    
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupColorPicker(){
        picker.selectedColor = self.view.backgroundColor ?? #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    }
    
    private func setupNavigationController(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        navigationItem.rightBarButtonItems = [saveButton]
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
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
    
    private func basedValueForModel(){
        let color = cellBackgroundColor.encode()
        scheduleModel.scheduleColor = color
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
        let inheritedData = testScheduleModel
        let data = cellsName[indexPath.section][indexPath.row]
        let date = inheritedData?.scheduleDate ?? Date()
        let time = inheritedData?.scheduleTime ?? Date()
        
        cell.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = .systemBackground
        
        let switchButton = UISwitch(frame: .zero)
        switchButton.isOn = false
        switchButton.isHidden = true
        switchButton.onTintColor = cellBackgroundColor
        switchButton.addTarget(self, action: #selector(self.didTapSwitch(sender: )), for: .touchUpInside)
        cell.accessoryView = switchButton
        
        if inheritedData != nil {
            switch indexPath {
            case [0,0]:
                cell.textLabel?.text = inheritedData?.scheduleName
            case [1,0]:
                cell.textLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            case [1,1]:
                cell.textLabel?.text = DateFormatter.localizedString(from: time, dateStyle: .none, timeStyle: .medium)
            case[2,0]:
                cell.textLabel?.text = inheritedData?.scheduleCategoryName ?? data
            case [2,1]:
                cell.textLabel?.text = inheritedData?.scheduleCategoryType ?? data
            case [2,2]:
                cell.textLabel?.text = inheritedData?.scheduleCategoryURL ?? data
            case [2,3]:
                cell.textLabel?.text = inheritedData?.scheduleCategoryNote ?? data
            case [3,0]:
                cell.backgroundColor = UIColor.color(withData: (inheritedData?.scheduleColor)!)
            case [4,0]:
                cell.textLabel?.text = data
                cell.accessoryView?.isHidden = false
                switchButton.isOn = ((inheritedData?.scheduleRepeat) != nil)
            default:
                alertError(text: "Please,try again later\nError getting data", mainTitle: "Error!!")
            }
        } else {
            cell.textLabel?.text = data
            if indexPath == [3,0] {
                cell.backgroundColor = cellBackgroundColor
            } else if indexPath == [4,0] {
                cell.accessoryView?.isHidden = false
            }
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellName = cellsName[indexPath.section][indexPath.row]
        if isEditingView {
            tableView.allowsSelection = false
        } else {
            switch indexPath {
            case [0,0]:
                alertTextField(cell: cellName, placeholder: "Enter text", keyboard: .default, table: tableView) { [self] text in
                    scheduleModel.scheduleName = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [1,0]:
                alertDate( table: tableView) { [self] weekday, date, dateString in
                    scheduleModel.scheduleDate = date
                    scheduleModel.scheduleWeekday = weekday
                    cellsName[indexPath.section][indexPath.row] = dateString
                }
            case [1,1]:
                alertTime(table: tableView) { [self] date, timeString in
                    scheduleModel.scheduleTime = date
                    cellsName[indexPath.section][indexPath.row] = timeString
                }
            case [2,0]:
                alertTextField(cell: "Enter Name of event", placeholder: "Enter the text", keyboard: .default, table: tableView) { [self] text in
                    scheduleModel.scheduleCategoryName = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [2,1]:
                alertTextField(cell: "Enter Type of event", placeholder: "Enter the text", keyboard: .default, table: tableView) { [self] text in
                    scheduleModel.scheduleCategoryType = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [2,2]:
                alertTextField(cell: "Enter URL of event", placeholder: "Enter the text", keyboard: .emailAddress, table: tableView) { [self] text in
                    scheduleModel.scheduleCategoryURL = text
                    cellsName[indexPath.section][indexPath.row] = text
                }
            case [2,3]:
                alertTextField(cell: "Enter Notes of event", placeholder: "Enter the text", keyboard: .default, table: tableView) { [self] text in
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        45
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
        DispatchQueue.main.async {
            self.scheduleModel.scheduleColor = encodeColor
            self.tableView.reloadData()
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(0)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(0)
        }
    }
}
