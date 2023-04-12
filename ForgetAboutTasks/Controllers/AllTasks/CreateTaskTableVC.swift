//
//  AllTasksOptionsTableView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 05.04.2023.
//

import UIKit
import SnapKit
import Combine

protocol TaskModelProtocol: AnyObject {
    func getData(data: TaskModel)
}

class CreateTaskTableViewController: UIViewController {
    
    weak var delegate: TaskModelProtocol?
    
    let headerArray = ["Name","Date","Notes","URL","Color accent"]
    
    var cellsName = [["Name of event"],
                     ["Date and Time"],
                     ["Notes"],
                     ["URL"],
                     [""]]
    
    var cellData = TaskModel(nameTask: "", dateTask: "", noteTask: "", urlTask: "", colorTask: #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1))

    var cellBackgroundColor =  #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
    var isCellSelectedFromTable: Bool = false
    
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

        delegate?.getData(data: cellData)
        self.dismiss(animated: true)
        
    }
    
    @objc private func didTapEdit(sender: Bool){
        
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
        if isCellSelectedFromTable == true {
            tableView.allowsSelection = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit(sender: )))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
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
        cell.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = .systemBackground
        if isCellSelectedFromTable == false {
            let data = cellsName[indexPath.section][indexPath.row]
            cell.textLabel?.text = data
            if indexPath == [4,0] {
                cell.backgroundColor = cellBackgroundColor
            }
        } else {
            switch indexPath {
            case [0,0]:
                cell.textLabel?.text = cellData.nameTask
            case [1,0]:
                cell.textLabel?.text = cellData.dateTask
            case [2,0]:
                cell.textLabel?.text = cellData.noteTask
            case [3,0]:
                cell.textLabel?.text = cellData.urlTask
            case [4,0]:
                cell.backgroundColor = cellData.colorTask
            default:
                print("error")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellName = cellsName[indexPath.section][indexPath.row]
        switch indexPath {
        case [0,0]:
            alertTextField(cell: cellName, placeholder: "Enter title of event", table: tableView) { [self] text in
                cellsName[indexPath.section][indexPath.row] = text
                cellData.nameTask = text
            }
        case [1,0]:
            alertDate(table: tableView) { [self] weekday, date, dateString in
                cellsName[indexPath.section][indexPath.row] += ": " + dateString
                cellData.dateTask = dateString
            }
        case [2,0]:
            alertTextField(cell: cellName, placeholder: "Enter notes value", table: tableView) { [self] text in
                cellsName[indexPath.section][indexPath.row] = text
                cellData.noteTask = text
            }
        case [3,0]:
            alertTextField(cell: cellName, placeholder: "Enter URL value", table: tableView, completion: { [self] text in
                cellsName[indexPath.section][indexPath.row] = text
                cellData.urlTask = text
            })
        case [4,0]:
            openColorPicker()
            cellData.colorTask = cellBackgroundColor
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
    
}

extension CreateTaskTableViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        cellBackgroundColor = color
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension CreateTaskTableViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {}
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
