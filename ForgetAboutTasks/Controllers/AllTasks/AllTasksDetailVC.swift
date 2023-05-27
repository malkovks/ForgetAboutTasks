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
    
    private let headerArray = ["Name","Date","Time","Notes","URL","Color accent"]
    private var cellsName = [["Name of event"],
                     ["Date"],
                     ["Time"],
                     ["Notes"],
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
    var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    let picker = UIColorPickerViewController()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private lazy var shareTableInfo: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up.fill"), style: .done, target: self, action: #selector(didTapShareTable))
    }()
    //MARK: - view loading
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
        let color = UIColor.color(withData: tasksModel.allTaskColor!) ?? #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        let vc = EditTaskTableViewController(color: color, model: tasksModel)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .formSheet
        navVC.sheetPresentationController?.detents = [.large()]
        navVC.sheetPresentationController?.prefersGrabberVisible = true
        navVC.isNavigationBarHidden = false
        present(navVC, animated: true)
    }
    
    @objc private func didTapShareTable(_ sender: Any){
        let vc = UIActivityViewController(activityItems: [tableView], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        vc.setValue("Table title", forKey: "subject")
        vc.excludedActivityTypes = [.markupAsPDF,.airDrop,.mail,.openInIBooks]
        present(vc, animated: true)
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
            default:
                alertError()
            }
            UIPasteboard.general.string = model
            alertDismissed(view: self.view)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    //MARK: - Setup methods
    private func setupView() {
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
        picker.selectedColor = UIColor(named: "navigationControllerColor") ?? #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
    }
    
    private func setupNavigationController(){
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
        navigationItem.rightBarButtonItems = [editButton,shareTableInfo]
        
        
    }
    //MARK: - Segue methods
    //methods with dispatch of displaying color in cell while choosing color in picker view
    @objc private func openColorPicker(){
        self.cancellable = picker.publisher(for: \.selectedColor) .sink(receiveValue: { color in
            DispatchQueue.main.async {
                self.cellBackgroundColor = color
            }
        })
        self.present(picker, animated: true)
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
        switch indexPath {
        case [0,0]:
            cell.textLabel?.text = tasksModel.allTaskNameEvent
        case [1,0]:
            cell.textLabel?.text = DateFormatter.localizedString(from: tasksModel.allTaskDate ?? Date(), dateStyle: .medium, timeStyle: .none)
        case [2,0]:
            cell.textLabel?.text = Formatters.instance.timeStringFromDate(date: tasksModel.allTaskTime ?? Date())
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
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 4 {
            let url = tasksModel.allTaskURL ?? "Empty URL"
            if url.isURLValid(text: url) {
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
