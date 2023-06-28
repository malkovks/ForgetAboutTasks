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
    
    private let realm = try! Realm()
    private var scheduleModel: Results<ScheduleModel>
    private var scheduleDates: [Date]
    
    private var dictionaryScheduleModel = [String: [ScheduleModel]]()
    private var sectionHeaderModel = [String]()
    
    init(model: Results<ScheduleModel>){
        let date = model.map({ $0.scheduleStartDate ?? Date ()}).sorted()
        self.scheduleModel = model.sorted(byKeyPath: "scheduleStartDate")
        self.scheduleDates = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - UI elements
    private let tableView = UITableView(frame: .null, style: .grouped)
    
    //MARK: - Setup viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    //MARK: - Target methods
    @objc private func didTapOpenCalendar(){
        alertDate(choosenDate: Date()) { _, date, text in
            let model = self.realm.objects(ScheduleModel.self).filter("scheduleStartDate == %@", date)
            self.scheduleModel = model
            self.tableView.reloadData()
        }
    }
    
    //MARK: - main setups
    private func setupView(){
        createSectionDictionary()
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
        title = "All events".localized()
    }
}
//MARK: - Table view delegate
extension ScheduleAllEventViewController: UITableViewDelegate, UITableViewDataSource {
    private func createSectionDictionary(){
        for model in scheduleModel {
            let date = model.scheduleStartDate ?? Date()
            let key = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            
            if var value = dictionaryScheduleModel[key] {
                value.append(model)
                dictionaryScheduleModel[key] = value
            } else {
                dictionaryScheduleModel[key] = [model]
            }
        }
        
        sectionHeaderModel = [String](dictionaryScheduleModel.keys).sorted(by: < )
    }
    
    private func setupSelectionCell(indexPath: IndexPath){
        let key = sectionHeaderModel[indexPath.section]
        if let data = dictionaryScheduleModel[key] {
            let value = data[indexPath.row]
            let vc = OpenTaskDetailViewController(model: value)
            show(vc, sender: nil)
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .fullScreen
//            nav.isNavigationBarHidden = false
//            present(nav, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaderModel.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaderModel[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sectionHeaderModel[section]
        guard let value = dictionaryScheduleModel[key] else { return 0}
        return value.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellAllEvent")
        let key = sectionHeaderModel[indexPath.section]
        if let values = dictionaryScheduleModel[key],
           let color = values[indexPath.row].scheduleColor {
            let value = values[indexPath.row]
            let startTime = DateFormatter.localizedString(from: value.scheduleStartDate ?? Date(), dateStyle: .none, timeStyle: .short)
            let endTime = DateFormatter.localizedString(from: value.scheduleEndDate ?? Date(), dateStyle: .none, timeStyle: .short)
            cell.textLabel?.text = value.scheduleName
            cell.detailTextLabel?.text = "Start - ".localized() + startTime +  ".End - ".localized() + endTime
            cell.imageView?.image = UIImage(systemName: "circle.fill")
            cell.imageView?.tintColor = UIColor.color(withData: color)
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setupSelectionCell(indexPath: indexPath)
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
