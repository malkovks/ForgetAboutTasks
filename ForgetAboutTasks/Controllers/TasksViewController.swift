//
//  TasksViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
//

import UIKit
import FSCalendar
import EventKit
import EventKitUI

protocol TasksViewDelegate: AnyObject {
    func tasksData(array data: [TasksDate], date: Date)
}

struct TasksDate {
    var date: String
    var dateGetter: Date?
    var time: String
    var name: String
    var event: EKEvent?
    var store: EKEventStore?
}

class TasksViewController: UIViewController {
    
    weak var delegate: TasksViewDelegate?
    
    public var dateGetter: Date?
    public var dateString: String?
    public var timeString: String?
    
    var cellData: [TasksDate] = []
    
    private var indexOfCell: Int = 0
    
    private let store = EKEventStore()
    
    
    private var calendar: FSCalendar = {
       let calendar = FSCalendar()
        calendar.scrollDirection = .vertical
        calendar.scope = .week
        calendar.firstWeekday = 2
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let saveButton: UIButton = {
       let button = UIButton()
        button.configuration = .tinted()
        button.configuration?.title = "Сохранить"
        button.configuration?.image = UIImage(systemName: "square.and.arrow.down.fill")
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 8
        button.configuration?.baseBackgroundColor = .systemBlue
        button.configuration?.baseForegroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationController()
        setupTableView()
//        setupConstraintsForCalendar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendar.frame = CGRect(x: 10, y: 90, width: view.frame.size.width-20, height: view.frame.size.height/4)
        tableView.frame = CGRect(x: 0, y: calendar.frame.size.height+10, width: view.frame.size.width, height: view.frame.size.height/1.7)
        saveButton.frame = CGRect(x: 30, y: calendar.frame.size.height+20+tableView.frame.size.height, width: view.frame.size.width-60, height: 55)
    }
 //MARK: - targets methods
    @objc private func didTapTapped(){
        if !cellData.isEmpty {
            setupAlertSheet(title: "Warning", subtitle: "Do you want to discard all changes?")
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc private func didTapCreate(){
        let alert = UIAlertController(title: "Hello!", message: "Please, enter the text", preferredStyle: .alert)
        alert.addTextField { (textfield: UITextField) -> Void in
            textfield.placeholder = "Enter the name of reminder"
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default,handler: { _ in
            let date = self.dateString
            guard let field = alert.textFields?.first,
                  let text = field.text, !text.isEmpty,
                  let time = self.timeString,
                  let date = date else { print("Error saving");return }
            
            self.cellData.append(TasksDate(date: date,time: time, name: text))
            self.tableView.reloadData()
            print("saved")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
//MARK: - Set up Methods
    private func setupAlertSheet(title: String,subtitle: String) {
        let sheet = UIAlertController(title: title, message: subtitle, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Discard changes", style: .destructive,handler: { _ in
            self.dismiss(animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Save", style: .default,handler: { [self] _ in
            self.delegate?.tasksData(array: cellData, date: dateGetter!)
            self.dismiss(animated: true)
            print("Data was saved")
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
    
    private func setupView(){
        setupTarget()
        view.addSubview(calendar)
        view.addSubview(tableView)
        view.addSubview(saveButton)
        calendar.delegate = self
        calendar.dataSource = self
        view.backgroundColor = .systemBackground
    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self
                           , forCellReuseIdentifier: "cell")
    }
    
    private func setupTarget(){
        
    }
    
    private func setupNavigationController(){
        title = "Задачи на \(dateString ?? "")"
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapTapped))
        let firstNav = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapCreate))
        firstNav.tintColor = .systemBlue
        navigationItem.rightBarButtonItems = [firstNav]
    }
  //функция конвертации текста и возврата в строку
//    private func cellConfigure() -> (String,String){
//
//    }
    

    
}
//MARK: - table delegates and datasource
extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let model = cellData[indexPath.row]
        cell.detailTextLabel?.text = model.date
        cell.textLabel?.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var comp = DateComponents()
        comp.day = 1
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: comp, to: dateGetter!)
        
        let model = cellData[indexPath.row]
        let event = EKEvent(eventStore: self.store)
        event.title = "\(model.name)"
        event.startDate = dateGetter
        event.endDate = endDate
        
        let eventVC = EKEventEditViewController()
        eventVC.event = event
        eventVC.eventStore = store
        eventVC.editViewDelegate = self
        present(eventVC, animated: true)
        indexOfCell = indexPath.row
    }
}

//MARK: - calendar delegates
extension TasksViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(date)
    }
}

//MARK: - events delegate
extension TasksViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        if action == .canceled {
            self.dismiss(animated: true)
        } else if action == .saved {
            let title = controller.event?.title
            var model = cellData[indexOfCell]
            model.name = title ?? "Error of setting string"
            model.event = controller.event
            model.store = controller.eventStore
            self.tableView.reloadData()
            self.dismiss(animated: true)
        }
        
    }
    
    
}
//MARK: - constrain extension for dymanic height changing
extension TasksViewController {
    func setupConstraintsForCalendar(){
        view.addSubview(calendar)
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: view.topAnchor, constant: 90),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 0),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: 0)
        ])
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: calendar.bottomAnchor,constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor , constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
//            tableView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 10)
        ])
        
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 30),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -90)
        ])
    }
}
