//
//  AllTasksOptionsTableView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 05.04.2023.
//

import UIKit
import SnapKit
import Combine

class CreateTaskTableViewController: UIViewController {
    
    let headerArray = ["Name","Date","Notes","URL","Color accent"]
    
    var cellsName = [["Name of event"],
                     ["Date and Time"],
                     ["Notes"],
                     ["URL"],
                     [""]]
    
    var cellBackgroundColor =  #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
    
    var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    
    let picker = UIColorPickerViewController()
    
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
        print("Save in table view of previous view")
    }
    
    @objc private func didTapSwitch(switchButton: UISwitch){
        if switchButton.isOn {
            print("Switch is on")
        } else {
            print("Switch is off")
        }
    }
    //MARK: - Setup methods
    private func setupView() {
        setupNavigationController()
        setupDelegate()
        setupColorPicker()
        setupConstraints()
        view.backgroundColor = .secondarySystemBackground
        title = "New task"
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tasksCell")
    }
    
    private func setupColorPicker(){
        picker.selectedColor = self.view.backgroundColor ?? #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
    }
    
    private func setupNavigationController(){
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
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

extension CreateTaskTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksCell", for: indexPath)
        let data = cellsName[indexPath.section][indexPath.row]
        cell.textLabel?.text = data
        cell.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = .systemBackground
        
        if indexPath == [4,0] {
            cell.backgroundColor = cellBackgroundColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellName = cellsName[indexPath.section][indexPath.row]
        switch indexPath {
        case [0,0]:
            alertTextField(cell: cellName, placeholder: "Enter title of event", table: tableView) { [self] text in
                self.cellsName[indexPath.section][indexPath.row] = text
                cellsName[indexPath.section][indexPath.row] = text
            }
        case [1,0]:
            alertDate(table: tableView) { weekday, date, dateString in
                self.cellsName[indexPath.section][indexPath.row] += ": " + dateString
            }
            alertTime(table: tableView) { date, time in
                self.cellsName[indexPath.section][indexPath.row] += ".Time : " + time
            }
        case [2,0]:
            alertTextField(cell: cellName, placeholder: "Enter notes value", table: tableView) { text in
                self.cellsName[indexPath.section][indexPath.row] = text
            }
        case [3,0]:
            alertTextField(cell: cellName, placeholder: "Enter URL value", table: tableView, completion: { text in
                self.cellsName[indexPath.section][indexPath.row] = text
            })
        case [4,0]:
            openColorPicker()
            
        default:
            print("error")
        }
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerArray[section]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        45
    }
    

    
}

extension CreateTaskTableViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        cellBackgroundColor = color
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension CreateTaskTableViewController: SetDateProtocol {
    func datePicker(sendDate: String) {

        cellsName[1][0] = "Date: "+sendDate
        tableView.reloadData()
    }
}

extension CreateTaskTableViewController: SetTimeProtocol {
    func timePicker(sendTime: String) {
        cellsName[1][1] = "Time: "+sendTime
        tableView.reloadData()
    }
}

extension CreateTaskTableViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
    }
}

extension CreateTaskTableViewController {
    private func setupConstraints(){
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(0)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(0)
        }
    }
}
