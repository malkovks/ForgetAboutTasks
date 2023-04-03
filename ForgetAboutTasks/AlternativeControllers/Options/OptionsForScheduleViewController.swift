//
//  OptionsForScheduleViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 17.03.2023.
//

import UIKit
import SnapKit

class OptionsForScheduleViewController: UIViewController {
    
    let headerArray = ["Date and time","Details of event","Category of event","Color of event","Repeat"]
    
    var cellsName = [["Name of event"],
                     ["Date", "Time"],
                     ["Name","Type","URL","Note"],
                     [""],
                     ["Repeat every 7 days"]]
    
    

    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
        // Do any additional setup after loading the view.
    }

    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    @objc private func didTapSave(){
        print("Save in table view of previous view")
    }
    
    private func setupView() {
        setupNavigationController()
        setupDelegate()
        view.backgroundColor = .secondarySystemBackground
        title = "Options"
//        navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupDelegate(){
        let firstVC = SetDateViewController()
        firstVC.delegate = self
        let secondVC = SetTimeViewController()
        secondVC.delegate = self
    }
    
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "options")
        tableView.register(OptionsTableViewCell.self, forCellReuseIdentifier: OptionsTableViewCell.identifier)
        setupConstraints()
    }
    
    private func setupNavigationController(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
    }
    
    private func alertTextForCell(text title:String,handler: @escaping ((String)->Void)){
        let alert = UIAlertController(title: "", message: "Enter text in \(title)", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = title
//            handler(field.text ?? "")
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { _ in
            handler(alert.textFields?[0].text ?? "")
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: OptionsTableViewCell.identifier, for: indexPath) as! OptionsTableViewCell
        cell.configureCell(indexPath: indexPath)
//        var cell = UITableViewCell(style: .subtitle, reuseIdentifier: "options")
//        let data = cellsName[indexPath.section][indexPath.row]
//        cell.layer.cornerRadius = 12
//        cell.textLabel?.text = data
//        cell.backgroundColor = .systemBackground
//        if indexPath.section == 3 {
//            cell.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//            cell.textLabel?.text = ""
//        } else if indexPath.section == 4 {
//            let switchButton = UISwitch()
//            switchButton.isOn = true
//            switchButton.onTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//            cell.accessoryView = switchButton as UIView
//        } else if indexPath.section == 1 {
//            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "options")
//            cell.textLabel?.text = data
//            cell.textLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
//        } else if indexPath.section == 2 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: OptionsTableViewCell.identifier, for: indexPath) as! OptionsTableViewCell
//            cell.configureCell(indexPath: indexPath)
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var cell = tableView.dequeueReusableCell(withIdentifier: "options")
        let customCell = tableView.dequeueReusableCell(withIdentifier: OptionsTableViewCell.identifier) as! OptionsTableViewCell
        switch indexPath {
        case [1,0]:
            alertDate(label: customCell.nameCellLabel) { weekday, date, dateString in
                print(weekday,date,dateString)
            }
        case [2,indexPath.row]:
            print("third section")
            
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
