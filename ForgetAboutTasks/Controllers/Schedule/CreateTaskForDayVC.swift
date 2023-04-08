//
//  TasksViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
//

import UIKit
import FSCalendar
import SnapKit

class CreateTaskForDayController: UIViewController {
    
    weak var delegate: TasksViewDelegate?
    
    public var choosenDate = Date()
    var cellData: [TasksDate] = []
    private var isValueWasChanged = Bool()
    private var isTrailingSwipeActionActive = Bool()
    
    
    private var indexOfCell = Int()
    private var isCellEdited = Bool()

    
    
    private var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.scrollDirection = .vertical
        calendar.scope = .week
        calendar.firstWeekday = 2
        calendar.weekdayHeight = 20
        calendar.headerHeight = 30
        calendar.pagingEnabled = true
        calendar.tintColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationController()
        setupTableViewAndDelegates()
        setupConstraintsForCalendar()
    }

 //MARK: -  actions targets methods
    @objc private func didTapTapped(){
        if !cellData.isEmpty && isValueWasChanged == true {
            //present alert and saving data
            setupAlertSheet(title: "Warning", subtitle: "What do you want to do with this list?")
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc private func didTapCreate(){
        let vc = OptionsForScheduleViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalTransitionStyle = .flipHorizontal
        navVC.modalPresentationStyle = .fullScreen
        navVC.isNavigationBarHidden = false
        present(navVC, animated: true)
    }
    
    @objc private func didTapEditCell(){
        if self.tableView.isEditing == true {
            tableView.isEditing = false
        } else {
            tableView.isEditing = true
        }
    }
//MARK: - Set up Methods
    private func getEndDate(start date: Date) -> Date? {
        var comp = DateComponents()
        comp.day = 1
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: comp, to: date)
        return endDate
    }
    
    private func setupAlertSheet(title: String,subtitle: String) {
        let date = Formatters.instance.stringFromDate(date: self.choosenDate)
        let sheet = UIAlertController(title: title, message: subtitle, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Discard changes", style: .destructive,handler: { _ in
            self.dismiss(animated: true)
            self.delegate?.tasksData(array: [],date: date)
        }))
        sheet.addAction(UIAlertAction(title: "Save", style: .default,handler: { [self] _ in
            self.delegate?.tasksData(array: cellData, date: date)
            self.dismiss(animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
    
    private func setupView(){
        view.backgroundColor = .systemBackground
        calendar.appearance.todayColor = UIColor.systemBlue
        calendar.today =  choosenDate
    }
    
    private func setupTableViewAndDelegates(){
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self
                           , forCellReuseIdentifier: "cell")
        calendar.delegate = self
        calendar.dataSource = self
    }
    
    
    private func setupNavigationController(){
        let convertDate = Formatters.instance.stringFromDate(date: choosenDate)
        title = "Задачи на \(convertDate)"
        
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapTapped))
        let firstBut = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapCreate))
        let secondBut = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(didTapEditCell))
        navigationItem.rightBarButtonItems = [firstBut, secondBut]
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        
    }
    
}
//MARK: - table delegates and datasource
extension CreateTaskForDayController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = cellData[indexPath.row].name
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        isValueWasChanged = true
        let index = indexPath.row
        let deleteInstance = UIContextualAction(style: .destructive, title: "") { [self] _, _, _ in
            self.cellData.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteInstance.backgroundColor = .systemRed
        deleteInstance.image = UIImage(systemName: "trash.fill")
        deleteInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [deleteInstance])
        
        return action
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        isTrailingSwipeActionActive = true
        let index = indexPath.row
        indexOfCell = index
        isCellEdited = true
//        let model = cellData[index]
        let actionInstance = UIContextualAction(style: .normal, title: "") { [weak self] _, _, completionHandler in
            self?.isTrailingSwipeActionActive = false
        }
        actionInstance.backgroundColor = .systemYellow
        actionInstance.image = UIImage(systemName: "pencil.line")
        actionInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [actionInstance])
        return action
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        isTrailingSwipeActionActive = false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = cellData[sourceIndexPath.row]
        cellData.remove(at: sourceIndexPath.row)
        cellData.insert(item, at: destinationIndexPath.row)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
    }
}

//MARK: - calendar delegates
extension CreateTaskForDayController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    }
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { make in
            make.height.equalTo(bounds.height)
        }
        self.view.layoutIfNeeded()
    }
}
//MARK: - constrain extension for dymanic height changing.NOT USING
extension CreateTaskForDayController {
    private func setupConstraintsForCalendar(){
        view.addSubview(calendar)
//        let height = view.frame.size.height/6
        calendar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
            
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom).offset(5)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
