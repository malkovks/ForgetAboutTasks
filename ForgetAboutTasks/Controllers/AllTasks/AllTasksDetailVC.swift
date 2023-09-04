//
//  AllTasksDetailVC.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 03.05.2023.
//

import UIKit
import SnapKit
import Combine
import SafariServices


class AllTasksDetailViewController: UIViewController {
    
    private let headerArray = ["Name".localized()
                               ,"Date".localized()
                               ,"Time".localized()
                               ,"Notes".localized()
                               ,"URL".localized()
                               ,"Color accent".localized()]
    private var cellsName = [
        ["Name of event".localized()],
        ["Date".localized()],
        ["Time".localized()],
        ["Notes".localized()],
        ["URL"],
        [""]]
    private var cellBackgroundColor =  #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    private var tasksModel = AllTaskModel()
    
    init(color: UIColor, model: AllTaskModel){
        self.tasksModel = model
        self.cellBackgroundColor = color
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - UI elements
    private var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    private let picker = UIColorPickerViewController()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var topMenu = UIMenu()
    
    private lazy var shareTableInfo: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up.fill"), menu: topMenu)
    }()
    
    //MARK: - view loading
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
    }

    //MARK: - Targets methods
    @objc private func didTapDismiss(){
        setupHapticMotion(style: .medium)
        dismiss(animated: isViewAnimated)
    }
    
    @objc private func didTapEdit(){
        setupHapticMotion(style: .rigid)
        let color = UIColor.color(withData: tasksModel.allTaskColor!) ?? #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        guard let vc = EditTaskTableViewController(color: color, model: tasksModel) else { return }
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .formSheet
        navVC.sheetPresentationController?.detents = [.large()]
        navVC.sheetPresentationController?.prefersGrabberVisible = true
        navVC.isNavigationBarHidden = false
        present(navVC, animated: isViewAnimated)
    }
    
    @objc private func didGesturePress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: tableView)
            guard let indexPath = tableView.indexPathForRow(at: point) else { return }
            var model: String?
                switch indexPath.section {
                case 0: model = tasksModel.allTaskNameEvent
                case 1: model = DateFormatter.localizedString(from: tasksModel.allTaskDate ?? Date(), dateStyle: .medium, timeStyle: .none)
                case 2: model = DateFormatter.localizedString(from: tasksModel.allTaskDate ?? Date(), dateStyle: .none, timeStyle: .short)
                case 3: model = tasksModel.allTaskNotes
                case 4: model = tasksModel.allTaskURL
                default: break }
            
            UIPasteboard.general.string = model
            alertDismissed(view: self.view)
            tableView.deselectRow(at: indexPath, animated: isViewAnimated)
        }
    }
    //MARK: - Setup methods
    private func setupView() {
        title = "Details".localized()
        setupMenu()
        setupNavigationController()
        setupDelegate()
        setupColorPicker()
        setupConstraints()
        view.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    private func setupDelegate(){
        picker.delegate = self
    }
    
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tasksCell")
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didGesturePress(_:)))
        tableView.addGestureRecognizer(gesture)
    }
    
    private func setupColorPicker(){
        picker.selectedColor = UIColor(named: "calendarHeaderColor") ?? #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    }
    
    private func setupNavigationController(){
        navigationController?.navigationBar.tintColor = UIColor(named: "calendarHeaderColor")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
        navigationItem.rightBarButtonItems = [editButton,shareTableInfo]
    }
    
    private func setupMenu(){
        let shareImage = UIAction(title: "Share Image".localized(), image: UIImage(systemName: "photo.circle.fill")) { _ in
            self.shareTableView("image")
        }
        let sharePDF = UIAction(title: "Share PDF File".localized(),image: UIImage(systemName: "doc.text.image.fill")) { _ in
            self.shareTableView("pdf")
        }
        topMenu = UIMenu(title: "Share selection".localized(), image: UIImage(systemName: "square.and.arrow.up"), options: .singleSelection , children: [shareImage,sharePDF])
    }
    
    func shareTableView(_ typeSharing: String) {
        setupHapticMotion(style: .rigid)
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
            alertError(text: "Error making screenshot of table view".localized()
                       , mainTitle: "Error!".localized())
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
        self.present(activityViewController, animated: isViewAnimated, completion: nil)
    }
    
    //MARK: - Segue methods
    //methods with dispatch of displaying color in cell while choosing color in picker view
    @objc private func openColorPicker(){
        setupHapticMotion(style: .medium)
        self.cancellable = picker.publisher(for: \.selectedColor) .sink(receiveValue: { color in
            DispatchQueue.main.async {
                self.cellBackgroundColor = color
            }
        })
        self.present(picker, animated: isViewAnimated)
    }
}
//MARK: - Table view delegates
extension AllTasksDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksCell", for: indexPath)

        cell.textLabel?.numberOfLines = 0
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(named: "cellColor")
        cell.textLabel?.font = .setMainLabelFont()
        switch indexPath {
        case [0,0]:
            cell.textLabel?.text = tasksModel.allTaskNameEvent
        case [1,0]:
            cell.textLabel?.text = DateFormatter.localizedString(from: tasksModel.allTaskDate ?? Date(), dateStyle: .medium, timeStyle: .none)
        case [2,0]:
            cell.textLabel?.text = DateFormatter.localizedString(from: tasksModel.allTaskTime ?? Date(), dateStyle: .none, timeStyle: .short)
        case [3,0]:
            cell.textLabel?.text = tasksModel.allTaskNotes
        case [4,0]:
            cell.textLabel?.text = tasksModel.allTaskURL
        case [5,0]:
            let color = UIColor.color(withData: tasksModel.allTaskColor!)
            cell.backgroundColor = color
        default:
            print("error")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: isViewAnimated)
        if indexPath.section == 4 {
            let url = tasksModel.allTaskURL ?? "Empty URL"
            if url.urlValidation(text: url) {
                futureUserActions(link: url)
            }
        }
    }
    

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerArray[section]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
}

extension AllTasksDetailViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        cellBackgroundColor = color
        let encodeColor = color.encode()
        DispatchQueue.main.async {
            self.tasksModel.allTaskColor = encodeColor
            self.tableView.reloadData()
        }
    }
}

extension AllTasksDetailViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {}
}

extension AllTasksDetailViewController {
    private func setupConstraints(){
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(0)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(0)
        }
    }
}
