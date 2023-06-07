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
    
    //MARK: - Setup viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    //MARK: - main setups
    private func setupView(){
        setupNavigationController()
        setupTableView()
        setupConstraints()
        view.backgroundColor = .clear
    }
    
    private func setupTableView(){
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellSearchResult")
    }

    
    private func setupNavigationController(){
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
    }

}
extension ScheduleSearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellSearchResult")
        let model = scheduleModel?[indexPath.row]
        cell.backgroundView?.tintColor = UIColor(named: "cellColor")
        
        let timeFF = Formatters.instance.timeStringFromDate(date: model?.scheduleStartDate ?? Date())
        let dateF = DateFormatter.localizedString(from: model?.scheduleTime ?? Date(), dateStyle: .medium, timeStyle: .none)
        
        cell.textLabel?.text = model?.scheduleName
        cell.detailTextLabel?.text =  dateF + ". Time: " + timeFF
        cell.imageView?.image = UIImage(systemName: "circle.fill")
        if let data = model?.scheduleColor {
            let color = UIColor.color(withData: data)
            cell.imageView?.tintColor = color
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleModel?.count ?? 10
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = scheduleModel?[indexPath.row] else { return }
        let vc = OpenTaskDetailViewController(model: model)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Result of search:"
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
