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
    
    var cellBackgroundColor =  #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
    
    
    
    private var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    
    private let picker = UIColorPickerViewController()
    private let scheduleModel = ScheduleModel()
    
    private let tableView = UITableView()
    
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
        print("Saved")
        
        RealmManager.shared.saveScheduleModel(model: scheduleModel)
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
    //MARK: - Setup methods
    private func setupView() {
        setupNavigationController()
        setupDelegate()
        setupColorPicker()
        setupConstraints()
        view.backgroundColor = .secondarySystemBackground
        title = "Options"
    }
    
    private func setupDelegate(){
        let firstVC = SetDateViewController()
        firstVC.delegate = self
        let secondVC = SetTimeViewController()
        secondVC.delegate = self
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
        picker.selectedColor = self.view.backgroundColor ?? #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
    }
    
    private func setupNavigationController(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
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
    
    @objc private func pushController(vc: UIViewController){
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        nav.sheetPresentationController?.detents = [.large()]
        nav.sheetPresentationController?.prefersGrabberVisible = true
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
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
        cell.textLabel?.text = data
        cell.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = .systemBackground
        
        let switchButton = UISwitch(frame: .zero)
        switchButton.isOn = false
        switchButton.isHidden = true
        switchButton.onTintColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        switchButton.addTarget(self, action: #selector(self.didTapSwitch(sender: )), for: .touchUpInside)
        cell.accessoryView = switchButton
        
        if indexPath == [3,0] {
            cell.backgroundColor = cellBackgroundColor
        } else if indexPath == [4,0] {
            cell.accessoryView?.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellName = cellsName[indexPath.section][indexPath.row]
        switch indexPath {
        case [0,0]:
            alertTextField(cell: cellName, placeholder: "Enter text", table: tableView) { [self] text in
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
            alertTextField(cell: "Enter Name of event", placeholder: "Enter the text", table: tableView) { [self] text in
                scheduleModel.scheduleCategoryName = text
                cellsName[indexPath.section][indexPath.row] = text
            }
        case [2,1]:
            alertTextField(cell: "Enter Type of event", placeholder: "Enter the text", table: tableView) { [self] text in
                scheduleModel.scheduleCategoryType = text
                cellsName[indexPath.section][indexPath.row] = text
            }
        case [2,2]:
            alertTextField(cell: "Enter URL of event", placeholder: "Enter the text", table: tableView) { [self] text in
                scheduleModel.scheduleCategoryURL = text
                cellsName[indexPath.section][indexPath.row] = text
            }
        case [2,3]:
            alertTextField(cell: "Enter Notes of event", placeholder: "Enter the text", table: tableView) { [self] text in
                scheduleModel.scheduleCategoryNote = text
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        45
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
}

extension OptionsForScheduleViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        cellBackgroundColor = color
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension OptionsForScheduleViewController: SetDateProtocol {
    func datePicker(sendDate: String) {

        cellsName[1][0] = "Date: "+sendDate
        tableView.reloadData()
    }
}

extension OptionsForScheduleViewController: SetTimeProtocol {
    func timePicker(sendTime: String) {
        cellsName[1][1] = "Time: "+sendTime
        tableView.reloadData()
    }
}

extension OptionsForScheduleViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
    }
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




//func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    tableView.deselectRow(at: indexPath, animated: true)
//    var cell = tableView.dequeueReusableCell(withIdentifier: "options")
//    let customCell = tableView.dequeueReusableCell(withIdentifier: OptionsTableViewCell.identifier, for: indexPath) as? OptionsTableViewCell
//    cell?.selectionStyle = .blue
//    let data = cellsName[indexPath.section][indexPath.row]
//    switch indexPath {
//    case [1,0]:
//        let vc = SetDateViewController()
//        vc.delegate = self
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .pageSheet
//        nav.sheetPresentationController?.detents = [.custom(resolver: { context in
//            self.view.frame.size.height/2
//        })]
//        nav.isNavigationBarHidden = false
//        nav.sheetPresentationController?.prefersGrabberVisible = true
//        present(nav, animated: true)
//    case [1,1]:
//        let vc = SetTimeViewController()
//        vc.delegate = self
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .pageSheet
//        nav.sheetPresentationController?.detents = [.custom(resolver: { context in
//            self.view.frame.size.height/4
//        })]
//        nav.isNavigationBarHidden = false
//        nav.sheetPresentationController?.prefersGrabberVisible = true
//        nav.presentationController?.delegate = self
//        present(nav, animated: true)
//        case [0,0]:
//            alertTextField(subtitle: "Test title") { text in
//                self.cellsName.remove(at: indexPath.row)
//                self.cellsName[0][0] = text
//                self.tableView.reloadData()
//            }
//    case [2,indexPath.row]:
//        print("third section")
//
//    default:
//        print("error")
//    }
//}
