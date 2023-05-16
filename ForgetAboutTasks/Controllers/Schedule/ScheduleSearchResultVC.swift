//
//  ScheduleSearchResultVC.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 14.05.2023.
//

import UIKit
import SnapKit
import RealmSwift

class ScheduleSearchResultViewController: UIViewController {
    
    var scheduleModel: Results<ScheduleModel>?
    
    let tableView = UITableView(frame: .null, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView(){
        setupNavigationController()
        setupTableView()
        setupConstraints()
        view.backgroundColor = .clear
    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellSearchResult")
    }
    
    private func setupNavigationController(){
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
    }
    
    func updateResult(model: Results<ScheduleModel>){
        scheduleModel = model
        tableView.reloadData()
    }
    

}
extension ScheduleSearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellSearchResult")
        let model = scheduleModel?[indexPath.row]
        cell.textLabel?.text = model?.scheduleCategoryName
        cell.detailTextLabel?.text =  String(describing: model?.scheduleDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleModel?.count ?? 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected at \(indexPath.row)")
    }
}

extension ScheduleSearchResultViewController {
    private func setupConstraints() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
