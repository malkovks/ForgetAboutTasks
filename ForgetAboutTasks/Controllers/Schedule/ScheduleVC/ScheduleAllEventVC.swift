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
    
    private lazy var filterTableData: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapOpenCalendar))
    }()
    
    //MARK: - Setup viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    //MARK: - Target methods
    @objc private func didTapOpenCalendar(){
        alertDate(table: tableView, choosenDate: Date()) { _, date, text in
            let model = self.realm.objects(ScheduleModel.self).filter("scheduleDate == %@", date)
            self.scheduleModel = model
        }
    }
    
    @objc private func handlerLongPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            let point = gesture.location(in: tableView)
            guard let indexPath = tableView.indexPathForRow(at: point) else { return }
            let menu = UIMenuController.shared
            let sharedItem = UIMenuItem(title: "Shared", action: #selector(handlerAction(_:)))
            let copyItem = UIMenuItem(title: "Copy", action: #selector(handlerCopy(_:)))
            menu.menuItems = [sharedItem,copyItem]
            menu.showMenu(from: tableView, rect: tableView.rectForRow(at: indexPath))

        }
    }

    @objc private func handlerAction(_ sender: Any){
        print("Shared")
    }

    @objc private func handlerCopy(_ indexPath: Any){
        print("Copy")
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
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handlerLongPress(_:)))
        tableView.addGestureRecognizer(gesture)
    }
    
    
    private func setupNavigationController(){
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationItem.rightBarButtonItem = filterTableData
        title = "All events"
    }
}
//MARK: - Table view delegate
extension ScheduleAllEventViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = scheduleDates[section]
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let dayName = formatter.string(from: date).capitalized
        return dayName + ", " + DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = scheduleDates[section]
        return scheduleModel.filter("scheduleDate == %@",date).count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
        cell.tintColor = UIColor(named: "cellColor")
        if let color = model.scheduleColor {
            cell.imageView?.tintColor = UIColor.color(withData: color)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let date = scheduleDates[indexPath.section]
        let event = scheduleModel.filter("scheduleDate == %@ ", date)
        let model = event[indexPath.row]
        let vc = OpenTaskDetailViewController(model: model)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editingData = scheduleModel[indexPath.row]
        let deleteInstance = UIContextualAction(style: .destructive, title: "") { _, _, _ in
            ScheduleRealmManager.shared.deleteScheduleModel(model: editingData)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteInstance.backgroundColor = .systemRed
        deleteInstance.image = UIImage(systemName: "trash.fill")
        deleteInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [deleteInstance])
        
        return action
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
