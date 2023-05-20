//
//  TaskDetailVC.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 30.04.2023.
//

import UIKit
import SnapKit
import SafariServices

class OpenTaskDetailViewController: UIViewController {
    
    let headerArray = ["Details of event","Date and time","Category of event","Color of event","Repeat"]
    
    var cellsName = [["Name of event"],
                     ["Date", "Time"],
                     ["Name","Type","URL","Note"],
                     [""],
                     ["Repeat every 7 days"]]
    
    var cellBackgroundColor =  #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    
    private var scheduleModel = ScheduleModel()
    var selectedScheduleModel = ScheduleModel()
    
    private lazy var shareModelButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareTable))
    }()
    
    private let tableView = UITableView(frame: CGRectZero, style: .insetGrouped)
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
    }

    //MARK: - Targets methods
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    @objc private func didTapEdit(){
        let vc = EditEventScheduleViewController()
        vc.scheduleModel = selectedScheduleModel
        vc.choosenDate = selectedScheduleModel.scheduleDate ?? Date()
        vc.cellBackgroundColor = UIColor.color(withData: selectedScheduleModel.scheduleColor!) ?? #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .crossDissolve
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    @objc private func didTapShareTable(){
        guard let pdfTable = convertTableIntoPDF(from: tableView) else { alertError();return}
        let activity = UIActivityViewController(activityItems: [pdfTable], applicationActivities: nil)
        activity.setValue("PDF Report", forKey: "subject")
        activity.excludedActivityTypes = [.print,.postToFlickr,.message,.mail,.markupAsPDF]
        activity.setValue("com.adobe.pdf", forKey: "fileType")
        present(activity, animated: true)
    }
    
    //MARK: - Setup Views and secondary methods
    private func setupView() {
        setupNavigationController()
        setupConstraints()
        view.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupNavigationController(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
        let saveButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
        navigationItem.rightBarButtonItems = [saveButton,shareModelButton]
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        title = "Details"
    }
    
    private func convertTableIntoPDF(from tableView: UITableView) -> Data? {
        let pdfBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let pdfDate = NSMutableData()
        UIGraphicsBeginPDFPageWithInfo(pdfBounds, nil)
        tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
        UIGraphicsEndPDFContext()
        return pdfDate as Data
    }
}
//MARK: - table view delegates and data sources
extension OpenTaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 4
        case 3: return 1
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let inheritedData = selectedScheduleModel
        let data = cellsName[indexPath.section][indexPath.row]
        let time = DateFormatter.localizedString(from: inheritedData.scheduleTime ?? Date(), dateStyle: .none, timeStyle:.short)
        let date = DateFormatter.localizedString(from: inheritedData.scheduleDate ?? Date(), dateStyle: .medium, timeStyle:.none)
        
        cell.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(named: "cellColor")
        cell.textLabel?.numberOfLines = 0
        
        let switchButton = UISwitch(frame: .zero)
        switchButton.isOn = false
        switchButton.isHidden = true
        switchButton.onTintColor = UIColor(named: "navigationControllerColor")
        cell.accessoryView = switchButton
        
        switch indexPath {
        case [0,0]:
            cell.textLabel?.text = inheritedData.scheduleName
        case [1,0]:
            cell.textLabel?.text = date + " Time: " + time
        case [1,1]:
            let content = UNMutableNotificationContent()
            if content.userInfo["userNotification"] as? String == date {
                switchButton.isOn = true
            } else {
                switchButton.isOn = false
            }
            cell.textLabel?.text = "Reminder status"
            cell.accessoryView?.isHidden = false
            switchButton.isEnabled = false
        case[2,0]:
            cell.textLabel?.text = inheritedData.scheduleCategoryName ?? data
        case [2,1]:
            cell.textLabel?.text = inheritedData.scheduleCategoryType ?? data
        case [2,2]:
            cell.textLabel?.text = inheritedData.scheduleCategoryURL ?? data
            let text = inheritedData.scheduleCategoryURL
            let success = text?.isURLValid(text: text ?? "")
            if success ?? true {
                cell.textLabel?.textColor = .systemBlue
            } else {
                cell.textLabel?.textColor = UIColor(named: "textColor")
            }
            
        case [2,3]:
            cell.textLabel?.text = inheritedData.scheduleCategoryNote ?? data
        case [3,0]:
            cell.backgroundColor = UIColor.color(withData: (inheritedData.scheduleColor)!)
        case [4,0]:
            cell.textLabel?.text = data
            cell.accessoryView?.isHidden = false
            switchButton.isOn = inheritedData.scheduleRepeat ?? false
            switchButton.isEnabled = false
        default:
            alertError(text: "Please,try again later\nError getting data", mainTitle: "Error!!")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == [2,2] {
            guard let url = selectedScheduleModel.scheduleCategoryURL else { return }
            futureUserActions(link: url)
        } else {
            tableView.allowsSelection = false
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerArray[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension OpenTaskDetailViewController {
    private func setupConstraints(){
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
