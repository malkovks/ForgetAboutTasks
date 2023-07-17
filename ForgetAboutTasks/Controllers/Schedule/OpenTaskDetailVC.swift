//
//  TaskDetailVC.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 30.04.2023.
//

import UIKit
import SnapKit
import RealmSwift
import SafariServices
import EventKit

class OpenTaskDetailViewController: UIViewController,CheckSuccessSaveProtocol {
    
    
    private let headerArray = ["Name of event".localized(),
                               "Date and time".localized(),
                               "Details of event".localized(),
                               "Color of event".localized(),
                               "Image".localized()]
    private var cellsName = [
                    ["Name of event".localized()],
                     ["Start".localized(),
                      "End".localized(),
                      "Reminder status".localized(),
                      "Added to Calendar".localized()],
                     ["Name".localized(),
                      "Type".localized(),
                      "URL".localized(),
                      "Note".localized()],
                     [""],
                     [""]]
    
    private var cellBackgroundColor =  #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    private var selectedScheduleModel: ScheduleModel
    private let fontSizeValue : CGFloat = CGFloat(UserDefaults.standard.float(forKey: "fontSizeChanging"))
    private let fontNameValue: String = UserDefaults.standard.string(forKey: "fontNameChanging") ?? "Charter"
    
    init(model: ScheduleModel) {
        self.selectedScheduleModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - UI Setups view
    private lazy var shareModelButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "gearshape.circle.fill"), menu: topMenu)
    }()
    
    private lazy var startEditButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
    }()
    
    private var topMenu = UIMenu()
    private let indicator =  UIActivityIndicatorView(style: .medium)
    
    private let tableView = UITableView(frame: CGRectZero, style: .insetGrouped)
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
    }

    //MARK: - Targets methods
    @objc private func didTapDismiss(){
        navigationController?.popViewController(animated: true)
        dismiss(animated: true)
    }
    
    @objc private func didTapEdit(){
        let colorCell = UIColor.color(withData: selectedScheduleModel.scheduleColor!) ?? #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        let choosenDate = selectedScheduleModel.scheduleStartDate ?? Date()
        let vc = EditEventScheduleViewController(cellBackgroundColor: colorCell, choosenDate: choosenDate, scheduleModel: selectedScheduleModel)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .crossDissolve
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    @objc private func didGesturePress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            let point = gesture.location(in: tableView)
            guard let indexPath = tableView.indexPathForRow(at: point) else { return }
            var model: String?
            switch indexPath {
            case [0,0]: model = selectedScheduleModel.scheduleName
            case [1,0]: model = DateFormatter.localizedString(from: selectedScheduleModel.scheduleStartDate ?? Date(), dateStyle: .medium, timeStyle: .short)
            case [2,0]: model = selectedScheduleModel.scheduleCategoryName
            case [2,1]: model = selectedScheduleModel.scheduleCategoryType
            case [2,3]: model = selectedScheduleModel.scheduleCategoryNote
            default:
                break
            }
            UIPasteboard.general.string = model
            showAlertForUser(text: "Text was copied".localized(), duration: DispatchTime.now()+0.5, controllerView: view)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc private func didTapLongPressOnImage(){
        guard let data = selectedScheduleModel.scheduleImage,
              let image = UIImage(data: data) else { return }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activity, animated: true)
    }
    
    //MARK: - Setup Views and secondary methods
    private func setupView() {
        setupMenu()
        setupNavigationController()
        setupConstraints()
        setupGestureForDismiss()
        indicator.hidesWhenStopped = true
        view.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    private func setupGestureForDismiss(){
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didTapDismiss))
        gesture.direction = .right
        view.addGestureRecognizer(gesture)
    }
    
    private func setupTableView(){
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.identifier)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didGesturePress(_:)))
        tableView.addGestureRecognizer(gesture)
        let cell = tableView.cellForRow(at: [4,0])
        cell?.imageView?.image = UIImage(data: selectedScheduleModel.scheduleImage!)
        cell?.imageView?.contentMode = .center
    }
    
    private func setupNavigationController(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
        navigationItem.rightBarButtonItems = [startEditButton,shareModelButton]
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        title = "Details".localized()
    }
    
    private func setupMenu(){
        let shareImage = UIAction(title: "Share Image".localized(), image: UIImage(systemName: "photo.circle.fill")) { _ in
            self.shareTableView("image")
        }
        let sharePDF = UIAction(title: "Share PDF File".localized(),image: UIImage(systemName: "doc.text.image.fill")) { _ in
            self.shareTableView("pdf")
        }
        let sectionShare = UIMenu(title: "Share".localized(),  options: .displayInline, children: [sharePDF,shareImage])
        let deleteCell = UIAction(title: "Delete".localized(),image: UIImage(systemName: "trash.fill"),attributes: .destructive) { _ in
            self.deleteModel()
        }
        topMenu = UIMenu(image: UIImage(systemName: "square.and.arrow.up"), children: [sectionShare,deleteCell])
    }
    
    private func shareTableView(_ typeSharing: String) {
        //pdf render
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: tableView.bounds)
        let pdfData = pdfRenderer.pdfData { context in
            context.beginPage()
            tableView.drawHierarchy(in: tableView.bounds, afterScreenUpdates: true)
        }
        //screenshot render
        UIGraphicsBeginImageContextWithOptions(tableView.contentSize, false, 0.0)
        tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            alertError(text: "Error making screenshot of table view", mainTitle: "Error!")
            return
        }
        UIGraphicsEndImageContext()
        var activityItems = [Any]()
        if typeSharing == "image" {
            activityItems.append(image)
        } else {
            activityItems.append(pdfData)
        }
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func deleteModel(){
        let alert = UIAlertController(title: "Warning!".localized(),
                                      message: "Do you want to delete event?".localized(), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete".localized(),
                                      style: .destructive,handler: { _ in
            ScheduleRealmManager.shared.deleteScheduleModel(model: self.selectedScheduleModel)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(),style: .cancel))
        present(alert, animated: true)
    }
    
    
    
    private func checkPlannedNotification() -> Bool {
        if selectedScheduleModel.scheduleActiveNotification == true {
            return true
        } else {
            return false
        }
    }
    
    private func checkInsertedEvent() -> Bool{
        if selectedScheduleModel.scheduleActiveCalendar == true {
            return true
        } else {
            return false
        }
    }
    
    func isSavedCompletely(boolean: Bool) {
        if boolean {
            tableView.reloadData()
            showAlertForUser(text: "Event was edited!".localized(), duration: DispatchTime.now()+1, controllerView: view)
        }
    }
}

//MARK: - table view delegates and data sources
extension OpenTaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.identifier) as? ScheduleTableViewCell
        if indexPath == [4,0] && cell?.imageViewSchedule.image != UIImage(systemName: "camera.fill"){
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions in
                let shareAction =
                    UIAction(title: NSLocalizedString("Share Image", comment: ""),
                                image: UIImage(systemName: "square.and.arrow.up.circle.fill")) { action in
                        self.didTapLongPressOnImage()
                    }
                let copyAction =
                    UIAction(title: NSLocalizedString("Copy Image", comment: ""),
                                image: UIImage(systemName: "arrowshape.turn.up.right.circle.fill")) { action in
                        if let data = self.selectedScheduleModel.scheduleImage, let image = UIImage(data: data) {
                            UIPasteboard.general.image = image
                            self.alertDismissed(view: self.view, title: "Image copied")
                        } else {
                            self.alertError(text: "Can't copy image")
                        }
                    }
                return UIMenu(title: "", children: [shareAction,copyAction])
            }
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 4
        case 2: return 4
        case 3: return 1
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let customCell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.identifier) as? ScheduleTableViewCell
        let inheritedData = selectedScheduleModel
        let data = cellsName[indexPath.section][indexPath.row]
        let time = DateFormatter.localizedString(from: inheritedData.scheduleTime ?? Date(), dateStyle: .none, timeStyle:.short)
        let date = DateFormatter.localizedString(from: inheritedData.scheduleStartDate ?? Date(), dateStyle: .medium, timeStyle:.none)
        let endDate = DateFormatter.localizedString(from: inheritedData.scheduleEndDate ?? Date(), dateStyle: .medium, timeStyle: .none)
        let endTime = DateFormatter.localizedString(from: inheritedData.scheduleEndDate ?? Date(), dateStyle: .none, timeStyle: .short)
        
        cell?.backgroundColor = UIColor(named: "cellColor")
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.font = UIFont(name: fontNameValue, size: fontSizeValue)
        
        let switchButton = UISwitch(frame: .zero)
        switchButton.isOn = false
        switchButton.isHidden = true
        switchButton.onTintColor = UIColor(named: "navigationControllerColor")
        cell?.accessoryView = switchButton
        
        switch indexPath {
        case [0,0]:
            cell?.textLabel?.text = inheritedData.scheduleName
        case [1,0]:
            cell?.textLabel?.text = date + " | " + time
        case [1,1]:
            cell?.textLabel?.text = endDate + " | " + endTime
        case [1,2]:
            cell?.textLabel?.text = data
            cell?.accessoryView?.isHidden = false
            switchButton.isEnabled = false
            switchButton.isOn = checkPlannedNotification()
        case [1,3]:
            cell?.textLabel?.text = data
            cell?.accessoryView?.isHidden = false
            switchButton.isEnabled = false
            switchButton.isOn = checkInsertedEvent()
        case[2,0]:
            cell?.textLabel?.text = inheritedData.scheduleCategoryName ?? data
        case [2,1]:
            cell?.textLabel?.text = inheritedData.scheduleCategoryType ?? data
        case [2,2]:
            cell?.textLabel?.text = inheritedData.scheduleCategoryURL ?? data
            let text = inheritedData.scheduleCategoryURL

            if let success = text?.isURLValid(text: text ?? "") , !success {
                cell?.textLabel?.textColor = .systemBlue
            } else {
                cell?.textLabel?.textColor = UIColor(named: "textColor")
            }
        case [2,3]:
            cell?.textLabel?.text = inheritedData.scheduleCategoryNote ?? data
        case [3,0]:
            cell?.backgroundColor = UIColor.color(withData: (inheritedData.scheduleColor)!)
        case [4,0]:
            let data = selectedScheduleModel.scheduleImage
            let image = UIImage(data: data ?? Data())
            customCell?.imageViewSchedule.image = image ?? UIImage(systemName: "camera.fill")
            return customCell!
        default:
            alertError(text: "Please,try again later\nError getting data", mainTitle: "Error!!")
        }
        return cell!
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
        if indexPath == [4,0] {
            return 300
        }
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
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        view.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.width.height.equalTo(50)
        }
    }
}
