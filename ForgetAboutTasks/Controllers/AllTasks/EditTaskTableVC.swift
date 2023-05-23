//
//  EditTaskTableVC.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 23.05.2023.
//

import UIKit
import SnapKit
import Combine
import RealmSwift


class EditTaskTableViewController: UIViewController {
    
    let headerArray = ["Name","Date","Time","Notes","URL","Color accent"]
    
    var cellsName = [["Name of event"],
                     ["Date"],
                     ["Time"],
                     ["Notes"],
                     ["URL"],
                     [""]]

    private var cellBackgroundColor: UIColor
    private var isStartEditing: Bool = false
    private var tasksModel: AllTaskModel
    private var editedTaskModel = AllTaskModel()
    
    init(color: UIColor,model: AllTaskModel){
        self.cellBackgroundColor = color
        self.tasksModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    
    let picker = UIColorPickerViewController()
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private lazy var navigationButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
    }()
    
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
            AllTasksRealmManager.shared.saveAllTasksModel(model: tasksModel)
            showAlertForUser(text: "Event saved successfully", duration: DispatchTime.now()+2, controllerView: view)
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                self.view.window?.rootViewController?.dismiss(animated: true)
            }
        } else {
            alertError(text: "Enter value in Name cell", mainTitle: "Error saving!")
        }
        
    }
    
    @objc private func didTapEdit(){
        
        if !editedTaskModel.allTaskNameEvent.isEmpty {
            editedTaskModel.allTaskColor = cellBackgroundColor.encode()
            let date = tasksModel.allTaskDate ?? Date()
            AllTasksRealmManager.shared.editAllTasksModel(oldModelDate: date, newModel: editedTaskModel)
            showAlertForUser(text: "Event edited successfully", duration: DispatchTime.now()+2, controllerView: view)
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                self.view.window?.rootViewController?.dismiss(animated: true)
            }
        } else {
            alertError(text: "Enter value in Name Section", mainTitle: "Error editing!")
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
        title = "Editing"
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
        tableView.allowsSelection = true
        navigationItem.rightBarButtonItem = navigationButton
        navigationButton.isEnabled = false
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
    
    private func setupCellTitle(model: AllTaskModel,indexPath: IndexPath){
        let date = model.allTaskDate ?? Date()
        let time = model.allTaskTime ?? Date()
        switch indexPath.section {
        case 0: cellsName[indexPath.section][indexPath.row] = model.allTaskNameEvent
        case 1: cellsName[indexPath.section][indexPath.row] = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        case 2: cellsName[indexPath.section][indexPath.row] = DateFormatter.localizedString(from: time, dateStyle: .none, timeStyle: .short)
        case 3: cellsName[indexPath.section][indexPath.row] = model.allTaskNotes ?? "Empty cell"
        case 4: cellsName[indexPath.section][indexPath.row] = model.allTaskURL ?? "Empty cell"
        default:
            print("Error")
        }
    }
}
//MARK: - Table view delegates
extension EditTaskTableViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksCell", for: indexPath)
        if !isStartEditing {
            setupCellTitle(model: tasksModel, indexPath: indexPath)
        }
        let data = cellsName[indexPath.section][indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(named: "cellColor")
        cell.textLabel?.text = data
        if indexPath.section == 5 {
            cell.backgroundColor = cellBackgroundColor
        }
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellName = cellsName[indexPath.section][indexPath.row]
    
        switch indexPath {
        case [0,0]:
            alertTextField(cell: cellName, placeholder: "Enter title of event", keyboard: .default, table: tableView) { [self] text in
                cellsName[indexPath.section][indexPath.row] = text
                editedTaskModel.allTaskNameEvent = text
                navigationButton.isEnabled = true
            }
        case [1,0]:
            alertDate(table: tableView, choosenDate: nil) { [self] _ , date, dateString in
                cellsName[indexPath.section][indexPath.row] += ": " + dateString
                editedTaskModel.allTaskDate = date
            }
        case [2,0]:
            alertTime(table: tableView, choosenDate: Date()) {  [self] date, timeString in
                cellsName[indexPath.section][indexPath.row] += ": " + timeString
                editedTaskModel.allTaskTime = date
            }
        case [3,0]:
            alertTextField(cell: cellName, placeholder: "Enter notes value", keyboard: .default, table:tableView) { [self] text in
                cellsName[indexPath.section][indexPath.row] = text
                editedTaskModel.allTaskNotes = text
            }
        case [4,0]:
            alertTextField(cell: cellName, placeholder: "Enter URL value", keyboard: .URL, table: tableView, completion: { [self] text in
                if text.isURLValid(text: text){
                    cellsName[indexPath.section][indexPath.row] = text
                    editedTaskModel.allTaskURL = text
                } else {
                    alertError(text: "Try again!\nEnter www. in URL link and pick a domain", mainTitle: "Warning!")
                }
            })
        case [5,0]:
            openColorPicker()
        default:
            print("error")
        
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

extension EditTaskTableViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        cellBackgroundColor = color
        let encodeColor = color.encode()
        self.tasksModel.allTaskColor = encodeColor
        self.tableView.reloadData()
    }
}

extension EditTaskTableViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {}
}

extension EditTaskTableViewController {
    private func setupConstraints(){
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(0)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(0)
        }
    }
}
