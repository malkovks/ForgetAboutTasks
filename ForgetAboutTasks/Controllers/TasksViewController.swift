//
//  TasksViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
//

import UIKit
import FSCalendar

class TasksViewController: UIViewController {
    
    private var calendarHeightConstraint: NSLayoutConstraint!
    
    private var calendar: FSCalendar = {
       let calendar = FSCalendar()
        calendar.scrollDirection = .vertical
        calendar.scope = .week
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
        setupTableView()
        setupConstraintsForCalendar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc private func didTapTapped(){
        if calendar.scope == .month {
            calendar.setScope(.week, animated: true)
            navigationItem.leftBarButtonItem?.image = UIImage(systemName: "eye.fill")
        } else {
            calendar.setScope(.month, animated: true)
            navigationItem.leftBarButtonItem?.image = UIImage(systemName: "eye.slash.fill")
        }
    }
    
    private func setupView(){
        setupTarget()
        view.addSubview(calendar)
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
        title = "Schedule"
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "eye.slash.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapTapped))
    }
    

    
}
//MARK: - table delegates and datasource
extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = "Check label"
        cell.detailTextLabel?.text = "Detail label"
        cell.imageView?.image = UIImage(systemName: "car")
        return cell
    }
}

//MARK: - calendar delegates
extension TasksViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint?.constant = bounds.height
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(date)
    }
}
//constrain extension for dymanic height changing
extension TasksViewController {
    func setupConstraintsForCalendar(){
        view.addSubview(calendar)
        calendarHeightConstraint = NSLayoutConstraint(item: calendar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        calendar.addConstraint(calendarHeightConstraint)
        
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
}
