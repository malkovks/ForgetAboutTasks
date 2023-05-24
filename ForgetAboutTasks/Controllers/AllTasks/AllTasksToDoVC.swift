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
    private var allTasksDataFiltered: Results<AllTaskModel>!
    private var localRealmData = try! Realm()
    var allTasksDataSections = [Date]()
    var taskDate = Set<Date>()
    
    private var viewIsFiltered: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return true }
        return text.isEmpty
    }
    
    private let tableView = UITableView()
    private let searchController = UISearchController()
    
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
        UIView.transition(with: tableView, duration: 0.3,options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Targets methods
    @objc private func didTapCreateNewTask(){
        let vc = CreateTaskTableViewController()
        vc.title = "New event"
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .formSheet
        navVC.sheetPresentationController?.detents = [.large()]
        navVC.sheetPresentationController?.prefersGrabberVisible = true
        navVC.isNavigationBarHidden = false
        present(navVC, animated: true)
    }
    
    @objc private func didTapRefresh(sender: AnyObject){
        UIView.transition(with: tableView, duration: 0.3,options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
    
    @objc private func didTapSearch(){
        navigationItem.searchController = searchController
        searchController.isActive = true
    }
    
    @objc private func didTapChangeCell(sender tag: AnyObject) {
        let button = tag as! UIButton
        let indexPath = IndexPath(row: button.tag, section: 0)
        let model = allTasksData[indexPath.row]
        let booleanValue = !model.allTaskCompleted
        AllTasksRealmManager.shared.changeCompleteStatus(model: model, boolean: booleanValue)
        loadingRealmData(typeOf: "allTaskCompleted",ascending: false)
        UIView.transition(with: tableView, duration: 0.3,options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Setup methods
    private func setupView(){
        setupConstraints()
        setupTableView()
        setupNavigationController()
        setupTargetsAndDelegates()
        loadingRealmData()
        setupSearchController()
        view.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    private func setupNavigationController(){
        title = "All Tasks"
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.fill.badge.plus"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapCreateNewTask))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass.circle.fill"), style: .done, target: self, action: #selector(didTapSearch))
    }
    
    private func setupTargetsAndDelegates(){
        refreshController.addTarget(self, action: #selector(didTapRefresh), for: .valueChanged)
        segmentalController.addTarget(self, action: #selector(didTapSegmentChanged), for: .valueChanged)
    }
    
    private func setupSearchController(){
        searchController.searchBar.placeholder = "Enter text"
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = nil
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func setupTableView(){
        tableView.refreshControl = refreshController
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    }
    //MARK: - Logic methods
    private func loadingRealmData(typeOf sort: String = "allTaskDate",ascending:Bool = true) {
        let secValue = localRealmData.objects(AllTaskModel.self).sorted(byKeyPath: sort,ascending: ascending)
        allTasksData = secValue
        UIView.transition(with: tableView, duration: 0.3,options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
    
    private func setupCategories(model: AllTaskModel) {
        allTasksDataSections.append(model.allTaskDate ?? Date())
        UIView.transition(with: tableView, duration: 0.3,options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
}

//MARK: - Table view delegates
extension AllTasksToDoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewIsFiltered ? allTasksDataFiltered.count : allTasksData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        let data = viewIsFiltered ?  allTasksDataFiltered[indexPath.row] : allTasksData[indexPath.row]
        let color = UIColor.color(withData: data.allTaskColor!)
        cell.backgroundColor = UIColor(named: "backgroundColor")

        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.tintColor = UIColor(named: "navigationControllerColor")
        button.addTarget(self, action: #selector(didTapChangeCell), for: .touchUpInside)
        button.sizeToFit()
        button.tag = indexPath.row

        cell.accessoryView = button as UIView
        cell.accessoryView?.tintColor = UIColor(named: "navigationControllerColor")
        
        let timeFF = Formatters.instance.timeStringFromDate(date: data.allTaskTime ?? Date())
        let dateF = DateFormatter.localizedString(from: data.allTaskDate ?? Date(), dateStyle: .medium, timeStyle: .none)
        cell.textLabel?.text = data.allTaskNameEvent
        cell.detailTextLabel?.text = dateF + " Time: " + timeFF
        cell.imageView?.image = UIImage(systemName: "circle.fill")
        
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
        let vc = AllTasksDetailViewController()
        vc.tasksModel = model
        vc.title = "Event details"
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
//MARK: - Search Controller:
extension AllTasksToDoViewController: UISearchResultsUpdating ,UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        filterTable(searchController.searchBar.text ?? "Empty value")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.searchController?.isActive = false
        navigationItem.searchController = nil
    }
    
    private func filterTable(_ searchText: String) {
        allTasksDataFiltered = allTasksData.filter("allTaskNameEvent CONTAINS[c] %@ ",searchText)
        UIView.transition(with: tableView, duration: 0.3,options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
}
//MARK: Contraints
extension AllTasksToDoViewController {
    private func setupConstraints(){
        
        view.addSubview(segmentalController)
        segmentalController.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
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
//MARK: - Setup for sections
//private func setupObjects() -> Results<AllTaskModel> {
//    let objects = localRealmData.objects(AllTaskModel.self).sorted(byKeyPath: "allTaskDate")
//    return objects
//}
//
//private func setupTitles(objects: Results<AllTaskModel>) -> ([String],[Date]) {
//    let dates = objects.map({ $0.allTaskDate! })
//    let uniqueDates = Array(Set(dates))
//    let sortedDates = uniqueDates.sorted(by: >)
//    let formatter = DateFormatter()
//    formatter.dateFormat = "dd MMMM yyyy"
//    let titles = sortedDates.map { formatter.string(from: $0) }
//    return (titles,sortedDates)
//}
//
//private func setupSectionsCategories(objects: Results<AllTaskModel>) -> [Date: [AllTaskModel]]  {
//    let objects = objects
//    var groupedObjects = [Date: [AllTaskModel]]()
//    for n in objects {
//        let date = n.allTaskDate ?? Date()
//        if groupedObjects[date] == nil {
//            groupedObjects[date] = [n]
//        } else {
//            groupedObjects[date]?.append(n)
//        }
//    }
//    return groupedObjects
//}
//
