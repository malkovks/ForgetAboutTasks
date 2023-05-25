//
//  ScheduleAllEventVC.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 25.05.2023.
//

import UIKit
import SnapKit
import RealmSwift

class ScheduleAllEventViewController: UIViewController {
    private var scheduleModel: Results<ScheduleModel>
    private var scheduleDates: [Date]
    
    init(model: Results<ScheduleModel>){
        let date = model.map({ $0.scheduleDate ?? Date ()}).sorted()
        self.scheduleModel = model.sorted(byKeyPath: "scheduleDate")
        self.scheduleDates = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private let tableView = UITableView(frame: .null, style: .grouped)
    
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
        view.backgroundColor = UIColor(named: "backgroundColor")
        
    }
    
    private func setupTableView(){
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellAllEvent")
    }

    
    private func setupNavigationController(){
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
    }

}
extension ScheduleAllEventViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = scheduleDates[section]
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.year,.month,.day], from: date)
        let dateFinal = calendar.date(from: comp)
        let dayName = formatter.string(from: date).capitalized
        print(dateFinal)
        return dayName + ", " + DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = scheduleDates[section]
        return scheduleModel.filter("scheduleDate == %@",date).count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        let calendar = Calendar.current
//        let comp = calendar.dateComponents([.year,.month,.day], from: Date()
        return scheduleDates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellAllEvent")
        let date = scheduleDates[indexPath.section]
        let event = scheduleModel.filter("scheduleDate == %@",date)
        
        let model = event[indexPath.row]
        let dateConvert = DateFormatter.localizedString(from: model.scheduleDate ?? Date(), dateStyle: .medium, timeStyle: .none)
        let timeConvert = DateFormatter.localizedString(from: model.scheduleTime ?? Date(), dateStyle: .none, timeStyle: .short)
        cell.textLabel?.text = model.scheduleName
        cell.detailTextLabel?.text = dateConvert + ", " + timeConvert
        cell.imageView?.image = UIImage(systemName: "circle.fill")
        if let color = model.scheduleColor {
            cell.imageView?.tintColor = UIColor.color(withData: color)
        }
        return cell
    }
    
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = scheduleModel[indexPath.row]
        let vc = OpenTaskDetailViewController(model: model)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
}

extension ScheduleAllEventViewController {
    private func setupConstraints() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
