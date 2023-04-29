//
//  AllTasksToDoViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//


import SnapKit
import UIKit
import RealmSwift

class AllTasksToDoViewController: UIViewController {
    
    var allTasksData: Results<AllTaskModel>!
    private var localRealmData = try! Realm()
    var allTasksDataSections = [Date]()
    var taskDate = Set<Date>()
    
    private let tableView = UITableView()
    
    private var segmentalController: UISegmentedControl = {
        let controller = UISegmentedControl(items: ["Date","A-Z"])
        controller.titleTextAttributes(for: .highlighted)
        controller.tintColor = UIColor(named: "navigationControllerColor")
        controller.backgroundColor = UIColor(named: "navigationControllerColor")
        controller.selectedSegmentIndex = 0
        controller.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    
    private let refreshController: UIRefreshControl = {
       let controller = UIRefreshControl()
        controller.tintColor = UIColor(named: "navigationControllerColor")
        controller.attributedTitle = NSAttributedString(string: "Pull to refresh")
        return controller
    }()

    //MARK: - Views loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //MARK: - Targets methods
    @objc private func didTapCreateNewTask(){
        let vc = CreateTaskTableViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .formSheet
        navVC.sheetPresentationController?.detents = [.large()]
        navVC.sheetPresentationController?.prefersGrabberVisible = true
        navVC.isNavigationBarHidden = false
        present(navVC, animated: true)
    }
    
    @objc private func didTapRefresh(sender: AnyObject){
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshController.endRefreshing()
        }
    }
    
    @objc private func didTapSegmentChanged(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            loadingRealmData(typeOf: "allTaskDate")
        } else if segment.selectedSegmentIndex == 1 {
            loadingRealmData(typeOf: "allTaskNameEvent")
        }
    }
    
    @objc private func didTapChangeCell(sender tag: AnyObject) {
        
        let button = tag as! UIButton
        let indexPath = IndexPath(row: button.tag, section: 0)
        let model = allTasksData[indexPath.row]
        let booleanValue = !model.allTaskCompleted
        AllTasksRealmManager.shared.changeAllTasksModel(model: model, boolean: booleanValue)
        tableView.reloadData()
    }
    
    //MARK: - Setup methods
    private func setupView(){
        setupConstraints()
        setupTableView()
        setupNavigationController()
        setupTargetsAndDelegates()
        loadingRealmData()
        view.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    private func setupNavigationController(){
        title = "All tasks"
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.fill.badge.plus"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapCreateNewTask))
    }
    
    private func setupTargetsAndDelegates(){
        refreshController.addTarget(self, action: #selector(didTapRefresh), for: .valueChanged)
        segmentalController.addTarget(self, action: #selector(didTapSegmentChanged), for: .valueChanged)
    }
    
    private func setupTableView(){
        tableView.refreshControl = refreshController
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    }
    //MARK: - Logic methods
    private func loadingRealmData(typeOf sort: String = "allTaskDate") {
        let secValue = localRealmData.objects(AllTaskModel.self).sorted(byKeyPath: sort)
        allTasksData = secValue
        self.tableView.reloadData()
    }
    
    private func setupCategories(model: AllTaskModel) {
        allTasksDataSections.append(model.allTaskDate ?? Date())
        self.tableView.reloadData()
    }
    
   
}
//MARK: - Task model protocol

//MARK: - Table view delegates
extension AllTasksToDoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTasksData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        let data = allTasksData[indexPath.row]
        let color = UIColor.color(withData: data.allTaskColor!)
        cell.backgroundColor = UIColor(named: "backgroundColor")
//        setupCategories(model: data)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.tintColor = UIColor(named: "navigationControllerColor")
        button.addTarget(self, action: #selector(didTapChangeCell), for: .touchUpInside)
        button.sizeToFit()
        button.tag = indexPath.row
        
        cell.accessoryView = button as UIView
        
        
        
        if let date = data.allTaskDate, let time = data.allTaskTime {
//            if allTasksDataSections[indexPath.section] == date {
                let timeFF = Formatters.instance.timeStringFromDate(date: time)
                let dateF = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    
                cell.textLabel?.text = data.allTaskNameEvent
                cell.detailTextLabel?.text = dateF + "   " + timeFF
                cell.imageView?.image = UIImage(systemName: "circle.fill")
//            }
            
        }
        if data.allTaskCompleted {
            button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            cell.textLabel?.textColor = .lightGray
            cell.detailTextLabel?.textColor = .lightGray
            cell.imageView?.tintColor = .lightGray
        } else {
            button.setImage(UIImage(systemName: "circle"), for: .normal)
            cell.textLabel?.textColor = UIColor(named: "textColor")
            cell.detailTextLabel?.textColor = UIColor(named: "textColor")
            cell.imageView?.tintColor = color
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = allTasksData[indexPath.row]
        let vc = CreateTaskTableViewController()
        vc.tasksModel = model
        vc.isCellSelectedFromTable = true
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        nav.isNavigationBarHidden = false
        nav.title = model.allTaskNameEvent
        nav.sheetPresentationController?.prefersGrabberVisible = true
        present(nav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let model = allTasksData[indexPath.row]
        let deleteInstance = UIContextualAction(style: .destructive, title: "") { _, _, _ in
            AllTasksRealmManager.shared.deleteAllTasks(model: model)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteInstance.backgroundColor = .systemRed
        deleteInstance.image = UIImage(systemName: "trash.fill")
        deleteInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [deleteInstance])
        
        return action
    }
}

extension AllTasksToDoViewController {
    private func setupConstraints(){
        
        view.addSubview(segmentalController)
        segmentalController.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentalController.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}


//func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let cell = tableView.cellForRow(at: indexPath)
//        let data = allTasksData[indexPath.row]
//        let color = UIColor.color(withData: data.allTaskColor!)
//        let actionInstance = UIContextualAction(style: .normal, title: "") { _, _, success in
//            if cell?.textLabel?.textColor == .lightGray {
//                cell?.textLabel?.textColor = .black
//                cell?.detailTextLabel?.textColor = .black
//                cell?.imageView?.image = UIImage(systemName: "circle.fill")
//                cell?.imageView?.tintColor = color
//                success(true)
//            } else {
//                cell?.textLabel?.textColor = .lightGray
//                cell?.imageView?.image = UIImage(systemName: "circle")
//                cell?.imageView?.tintColor = .lightGray
//                cell?.detailTextLabel?.textColor = .lightGray
//                success(true)
//            }
//
//        }
//        actionInstance.backgroundColor = .systemYellow
//        actionInstance.image = UIImage(systemName: "pencil.line")
//        actionInstance.image?.withTintColor(.systemBackground)
//        let action = UISwipeActionsConfiguration(actions: [actionInstance])
//        return action
//    }
