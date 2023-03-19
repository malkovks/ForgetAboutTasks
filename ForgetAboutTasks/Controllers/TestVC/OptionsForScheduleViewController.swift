//
//  OptionsForScheduleViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 17.03.2023.
//

import UIKit
import SnapKit

class OptionsForScheduleViewController: UIViewController {
    
    let headerArray = ["Date","Name of event","User name","Color of event","Timer"]
    
    let cellsName = [["Date", "Time"],
                     ["Name","Type","Building","Example of title"],
                     ["User Name"],
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
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
    
    private func setupView() {
        setupNavigationController()
        view.backgroundColor = .secondarySystemBackground
        title = "Options"
//        navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "options")
        setupConstraints()
    }
    
    private func setupNavigationController(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
    }

}

extension OptionsForScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 4
        case 2: return 1
        case 3: return 1
        default: return 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "options")
        let data = cellsName[indexPath.section][indexPath.row]
        cell.layer.cornerRadius = 12
        cell.textLabel?.text = data
        cell.backgroundColor = .systemBackground
        if indexPath.section == 3 {
            cell.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            cell.textLabel?.text = ""
        } else if indexPath.section == 4 {
            let switchButton = UISwitch()
            switchButton.isOn = true
            switchButton.onTintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            cell.accessoryView = switchButton as UIView
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.dequeueReusableCell(withIdentifier: "options",for: indexPath)
        guard let label = cell.textLabel else { print("Error set value"); return  }
        switch indexPath {
        case [0,0]: alertDate(label: label) { weekday, date in
            DispatchQueue.main.async {
                print(date)
                label.text = String(describing: date)
                self.tableView.reloadData()
            }
            
        }
        case [0,1]: alertTime(label: label) { date,string in
            print(string)
            label.text = string
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
            
        }
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

extension OptionsForScheduleViewController {
    private func setupConstraints(){
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(0)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(0)
        }
    }
}
