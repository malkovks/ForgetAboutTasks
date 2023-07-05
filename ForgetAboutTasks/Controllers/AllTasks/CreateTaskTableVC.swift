//
//  AllTasksOptionsTableView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 05.04.2023.
//

import UIKit
import SnapKit
import Combine
import RealmSwift




class CreateTaskTableViewController: UIViewController {
    
    weak var delegate: CheckSuccessSaveProtocol?
    
    private let headerArray = ["Name".localized()
                               ,"Date".localized()
                               ,"Time".localized()
                               ,"Notes".localized()
                               ,"URL"
                               ,"Color accent".localized()]
    private var cellsName = [
        ["Name of event".localized()],
                     ["Date".localized()],
                     ["Time".localized()],
                     ["Notes".localized()],
                     ["URL"],
                     [""]]
    private var cellBackgroundColor =  #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    private var tasksModel = AllTaskModel()
    
    private var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    private let picker = UIColorPickerViewController()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
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
        if !tasksModel.allTaskNameEvent.isEmpty {
            tasksModel.allTaskColor = cellBackgroundColor.encode()
            if tasksModel.allTaskDate == nil {
                tasksModel.allTaskDate = Date()
                AllTasksRealmManager.shared.saveAllTasksModel(model: tasksModel)
            } else if tasksModel.allTaskTime == nil {
                tasksModel.allTaskTime = Date()
                AllTasksRealmManager.shared.saveAllTasksModel(model: tasksModel)
            } else if tasksModel.allTaskTime == nil && tasksModel.allTaskDate == nil {
                tasksModel.allTaskDate = Date()
                tasksModel.allTaskTime = Date()
                AllTasksRealmManager.shared.saveAllTasksModel(model: tasksModel)
            } else {
                AllTasksRealmManager.shared.saveAllTasksModel(model: tasksModel)
            }
            delegate?.isSavedCompletely(boolean: true)
            dismiss(animated: true)
        } else {
            alertError(text: "Enter value in Name cell".localized(), mainTitle: "Error saving!".localized())
        }
        
    }
    //MARK: - Setup methods
    private func setupView() {
        setupNavigationController()
        setupDelegate()
        setupColorPicker()
        setupConstraints()
        view.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    private func setupDelegate(){
        picker.delegate = self
    }
    
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tasksCell")
    }
    
    private func setupColorPicker(){
        picker.selectedColor = UIColor(named: "navigationControllerColor") ?? #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    }
    
    private func setupNavigationController(){
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
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
}
//MARK: - Table view delegates
extension CreateTaskTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(named: "cellColor")
        let data = cellsName[indexPath.section][indexPath.row]
        cell.textLabel?.text = data
        if indexPath == [5,0] {
            cell.backgroundColor = cellBackgroundColor
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellName = cellsName[indexPath.section][indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        switch indexPath {
        case [0,0]:
            alertTextField(cell: cellName, placeholder: "Enter title of task".localized(), keyboard: .default) { [self] text in
                cellsName[indexPath.section][indexPath.row] = text
                tasksModel.allTaskNameEvent = text
                cell?.textLabel?.text = text
            }
        case [1,0]:
            alertDate( choosenDate: nil) { [self] _ , date, dateString in
                cellsName[indexPath.section][indexPath.row] = dateString
                tasksModel.allTaskDate = date
                cell?.textLabel?.text = dateString
            }
        case [2,0]:
            alertTime(choosenDate: Date()) {  [self] date, timeString in
                cellsName[indexPath.section][indexPath.row] = timeString
                tasksModel.allTaskTime = date
                cell?.textLabel?.text = timeString
            }
        case [3,0]:
            alertTextField(cell: cellName, placeholder: "Enter notes value".localized(), keyboard: .default) { [self] text in
                cellsName[indexPath.section][indexPath.row] = text
                tasksModel.allTaskNotes = text
                cell?.textLabel?.text = text
            }
        case [4,0]:
            alertTextField(cell: cellName, placeholder: "Enter URL value".localized(), keyboard: .URL) { [self] text in
                if text.isURLValid(text: text) {
                    cellsName[indexPath.section][indexPath.row] = text
                    tasksModel.allTaskURL = text
                    cell?.textLabel?.text = text
                } else {
                    alertError(text: "Enter name of URL link with correct domain".localized(), mainTitle: "Error!".localized())
                }
                
            }
        case [5,0]:
            openColorPicker()
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerArray[section]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 {
            return UITableView.automaticDimension
        }
        return 45
    }
    
}

extension CreateTaskTableViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        let cell = tableView.cellForRow(at: [5,0])
        cell?.backgroundColor = color
        cellBackgroundColor = color
        let encodeColor = color.encode()
        self.tasksModel.allTaskColor = encodeColor
        self.tableView.reloadData()
        
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
}
