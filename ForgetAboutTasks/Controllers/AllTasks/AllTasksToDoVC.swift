//
//  AllTasksToDoViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//


import SnapKit
import UIKit

class AllTasksToDoViewController: UIViewController {
    
    private var tasksData: [TaskModel] = [
        TaskModel(nameTask: "Test", dateTask: "Test", noteTask: "test", urlTask: "test", colorTask: .black),
        TaskModel(nameTask: "Test2", dateTask: "Test2", noteTask: "Test2", urlTask: "Test", colorTask: .systemRed),
        TaskModel(nameTask: "test3", dateTask: "Test3", noteTask: "Test3", urlTask: "Test3", colorTask: .systemBlue)
    ]
    
    private var isSwipeCompleted: Bool = false
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    //MARK: - Targets methods
    @objc private func didTapCreateNewTask(){
        let vc = CreateTaskTableViewController()
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .formSheet
        navVC.sheetPresentationController?.detents = [.large()]
        navVC.sheetPresentationController?.prefersGrabberVisible = true
        navVC.isNavigationBarHidden = false
        present(navVC, animated: true)
    }
    
    //MARK: - Setup methods

    
    private func setupView(){
        setupConstraints()
        setupTableView()
        setupNavigationController()
        view.backgroundColor = .lightGray
        
        let vc = CreateTaskTableViewController()
        vc.delegate = self
    }
    
    private func setupNavigationController(){
        title = "All tasks"
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.fill.badge.plus"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapCreateNewTask))
    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    }
}

extension AllTasksToDoViewController: TaskModelProtocol {
    func getData(data: TaskModel) {
        tasksData.append(data)
        tableView.backgroundView?.backgroundColor = data.colorTask
        self.tableView.reloadData()
        print(tasksData.count)
    }
    
    
}

extension AllTasksToDoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        if !tasksData.isEmpty {
            cell.textLabel?.text = tasksData[indexPath.row].nameTask
            cell.detailTextLabel?.text = "Cell detail test"
            cell.imageView?.image = UIImage(systemName: "circle.fill")
            cell.imageView?.tintColor = tasksData[indexPath.row].colorTask
            cell.accessoryType = .disclosureIndicator
        } else {
            print("Data is empty")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasksData[indexPath.row]
        let vc = CreateTaskTableViewController()
        vc.delegate = self
        vc.cellData = task
        vc.isCellSelectedFromTable = true
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        nav.isNavigationBarHidden = false
        nav.sheetPresentationController?.prefersGrabberVisible = true

        present(nav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let index = indexPath.row
        let deleteInstance = UIContextualAction(style: .destructive, title: "") { [self] _, _, _ in
            self.tasksData.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteInstance.backgroundColor = .systemRed
        deleteInstance.image = UIImage(systemName: "trash.fill")
        deleteInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [deleteInstance])
        
        return action
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        isSwipeCompleted = true
        let cell = tableView.cellForRow(at: indexPath)
        let actionInstance = UIContextualAction(style: .normal, title: "") { _, _, completionHandler in
            if cell?.textLabel?.textColor == .lightGray {
                cell?.textLabel?.textColor = .black
                cell?.detailTextLabel?.textColor = .black
                cell?.imageView?.tintColor = self.tasksData[indexPath.row].colorTask
                self.isSwipeCompleted = false
            } else {
                cell?.textLabel?.textColor = .lightGray
                cell?.imageView?.tintColor = .lightGray
                cell?.detailTextLabel?.textColor = .lightGray
                self.isSwipeCompleted = false
            }
            
        }
        self.isSwipeCompleted = false
        actionInstance.backgroundColor = .systemYellow
        actionInstance.image = UIImage(systemName: "pencil.line")
        actionInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [actionInstance])
        return action
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        isSwipeCompleted = false
    }
}

extension AllTasksToDoViewController {
    private func setupConstraints(){
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.horizontalEdges.verticalEdges.equalToSuperview()
        }
    }
}
