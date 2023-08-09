//
//  TaskBirthdayDetailVC.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 04.08.2023.
//

import UIKit
import SnapKit
import RealmSwift

final class TaskBirthdayDetailViewController: UIViewController {
    //properties and inits
    private var birthdayContactModel: Results<ContactModel>!
    private var currentDate: Date
    private var birthdayDictionary: [String:[ContactModel]] = [String:[ContactModel]]()
    private var convertedDate = String()
    private let realm = try! Realm()
    
    init(choosenDate: Date,birthdayModel: Results<ContactModel>){
        self.currentDate = choosenDate
        self.birthdayContactModel = birthdayModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //UI Elements
    private let tableView: UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "birthdayCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.bounces = false
        table.layer.cornerRadius = 12
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        filterContactModel()
//        filterModel(date: currentDate)
        
    }
    //MARK: - Targets
    @objc private func didTapDismiss(){
        self.dismiss(animated: true)
    }
    
    //MARK: - Setups
    

    
    private func setupView(){
        
        setupConstraints()
        setupNavigationController()
        setupTableView()
        view.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationController(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(didTapDismiss))
        navigationController?.navigationBar.tintColor = UIColor(named: "calendarHeaderColor")
        title = "Today's Birthday"
        navigationController?.navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupDateFilter(choosen date: Date) -> (Date,Date) {
        let dateStart = date
        let finalDateStart: Date = {
            let comp = DateComponents(hour: 00,minute: 00,second: 00)
            return Calendar.current.date(byAdding: comp, to: dateStart)!
        }()
        
        let dateEnd: Date = {
            let components = DateComponents(day:1, second: -1)
            return Calendar.current.date(byAdding: components, to: finalDateStart)!
        }()
        return (finalDateStart,dateEnd)
    }
    
    private func setupDateFilterWithoutYear(date: Date) -> (Date,Date){
        let startDate: Date = {
            let comp =  Calendar.current.dateComponents([.month,.day], from: date)
            return Calendar.current.date(byAdding: comp, to: date)!
        }()
        let endDate: Date = {
            let comp = DateComponents(day: 1,second: -1)
            return Calendar.current.date(byAdding: comp, to: startDate)!
        }()
        return (startDate,endDate)
    }
    
    private func filterModel(date: Date){
        let day = Calendar.current.dateComponents([.day], from: date).day!
        let month = Calendar.current.dateComponents([.month], from: date).month!
        
//        let predicate = NSPredicate(format: "MONTH(contactDateBirthday) == %d AND DAY(contactDateBirthday) == %d", month,day)
        let predicate = NSPredicate(format: "dateComponents([.month, .day], from: contactDateBirthday).month == %d AND dateComponents([.month, .day], from contactDateBirthday).day == %d", month,day)
        let models = realm.objects(ContactModel.self).filter(predicate)
        
    }
    
    private func filterContactModel(){
        let (dateStart,dateEnd) = setupDateFilter(choosen: currentDate)
//        let (dateStart,dateEnd) = setupDateFilterWithoutYear(date: currentDate)
        let realmModel = realm.objects(ContactModel.self)
            .filter("contactDateBirthday >=  %@ AND contactDateBirthday <= %@",dateStart,dateEnd)
//        birthdayContactModel = realmModel
        guard let birthdayModel = self.birthdayContactModel else { return }
        for birthday in birthdayModel {
            if let model = birthday.contactDateBirthday {
                let convertedModel = model.getDateWithoutYear(date: model,currentYearDate: currentDate)
                
                let dateString = DateFormatter.localizedString(from: model, dateStyle: .medium, timeStyle: .none)
//                print(dateString ,"Name \(birthday.contactName)")
                self.convertedDate = dateString
                
                self.birthdayDictionary[dateString]?.append(birthday)
            } else {
//                print("No birthday Date. Empty value")
            }
        }
//        print(birthdayDictionary)
    }
}

//MARK: - Extensions
extension TaskBirthdayDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        birthdayDictionary[convertedDate]?.count ?? 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "birthdayCell")
        guard let model = birthdayDictionary[convertedDate] else { return UITableViewCell() }
        cell.backgroundColor = .systemRed
        cell.textLabel?.text = model[indexPath.row].contactName ?? "Test"
        cell.detailTextLabel?.text = String(describing: model[indexPath.row].contactDateBirthday)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension TaskBirthdayDetailViewController {
    private func setupConstraints(){
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
