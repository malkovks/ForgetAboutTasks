//
//  AllTasksToDoViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//


import SnapKit
import UIKit

class AllTasksToDoViewController: UIViewController {
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    //MARK: - Targets methods
    @objc private func didTapCreateNewTask(){
        let vc = UINavigationController(rootViewController: CreateTaskTableViewController())
        vc.modalPresentationStyle = .formSheet
        vc.sheetPresentationController?.detents = [.large()]
        vc.sheetPresentationController?.prefersGrabberVisible = true
        vc.isNavigationBarHidden = false
        present(vc, animated: true)
    }
    
    //MARK: - Setup methods

    
    private func setupView(){
        setupConstraints()
        setupTableView()
        setupNavigationController()
        view.backgroundColor = .lightGray
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

extension AllTasksToDoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        cell.textLabel?.text = "Cell test"
        cell.detailTextLabel?.text = "Cell detail test"
        return cell
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
