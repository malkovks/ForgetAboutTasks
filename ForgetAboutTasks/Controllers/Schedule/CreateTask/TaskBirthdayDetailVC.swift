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
    private var birthdayModel: [ContactModel] = []
    private var convertedDate = String()
    private let realm = try! Realm()
    
    var isOpenContact: ((ContactModel) -> Void)?
    
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
        setupModel()
        setupView()
        
    }
    //MARK: - Targets
    @objc private func didTapDismiss(){
        setupHapticMotion(style: .soft)
        self.dismiss(animated: isViewAnimated)
    }
    
    //MARK: - Setups
    private func calculateBirthdayModel(models: Results<ContactModel>,currentDateString: String){
        for model in models {
            guard let birthday = model.contactDateBirthday else { continue }
            let modelDate = birthday.getDateWithoutYear(currentYearDate: currentDate)
            let modelDateString = DateFormatter.localizedString(from: modelDate, dateStyle: .medium, timeStyle: .none)
            if modelDateString == currentDateString {
                birthdayModel.append(model)
            }
            continue
        }
    }
    
    private func setupModel(){
        guard let model = birthdayContactModel else { return }
        let currentDateString = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        self.calculateBirthdayModel(models: birthdayContactModel, currentDateString: currentDateString)
    }

    
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(didTapDismiss))
        navigationController?.navigationBar.tintColor = UIColor(named: "calendarHeaderColor")
        let shortCurrentDate = DateFormatter.localizedString(from: currentDate, dateStyle: .short, timeStyle: .none)
        title = "Birthday's " + shortCurrentDate
        navigationController?.navigationItem.largeTitleDisplayMode = .never
    }
}

//MARK: - Extensions
extension TaskBirthdayDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        birthdayModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "birthdayCell")
        let model = birthdayModel[indexPath.row]
        
        let name = model.contactName ?? ""
        let secondName = model.contactSurname ?? ""
        let birthday = DateFormatter.localizedString(from: model.contactDateBirthday ?? Date(), dateStyle: .medium, timeStyle: .none)
        let age = "Age: ".localized() + String(describing: model.contactDateBirthday?.getContactUserAge(specifiedDate: currentDate) ?? 0)
        
        cell.tintColor = UIColor(named: "calendarHeaderColor")
        cell.textLabel?.text = name + " " + secondName
        cell.detailTextLabel?.text = age + ". Birthday date: ".localized() + birthday
        cell.imageView?.image = UIImage(systemName: "person.circle.fill")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: isViewAnimated)
        let model = birthdayModel[indexPath.row]
        let vc = EditContactViewController(contactModel: model, editing: false)
        isOpenContact?(model)
        dismiss(animated: isViewAnimated)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
