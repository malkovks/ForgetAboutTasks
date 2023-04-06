//
//  NewContactViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 06.04.2023.
//

import UIKit
import SnapKit
import Combine

class NewContactViewController: UIViewController {
    
    let headerArray = ["Name","Phone","Mail","Type"]
    
    var cellsName = [["Name"],
                     ["Phone number"],
                     ["Mail"],
                     ["Type of contact"]]
    
    var cellBackgroundColor =  #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
    
    var cancellable: AnyCancellable?//for parallels displaying color in cell and Combine Kit for it
    
    let picker = UIColorPickerViewController()
    
    private let tableView = UITableView()
    private let viewForTable = NewContactCustomView()
    
    private let labelForImageView: UILabel = {
       let label = UILabel()
        label.text = "Choose image:"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
    }

    //MARK: - Targets methods
    @objc private func didTapSave(){
        print("Save in table view of previous view")
    }
    
    @objc private func didTapOpenPhoto(){
        print("Opened photo album")
    }
    
    @objc private func didTapDismiss(){
        self.dismiss(animated: true)
    }
    
    //MARK: - Setup methods
    private func setupView() {
        setupNavigationController()
        setupDelegate()
        setupColorPicker()
        setupConstraints()
        customiseView()
        view.backgroundColor = .secondarySystemBackground
        title = "New Contact"
    }
    
    private func setupDelegate(){
        picker.delegate = self
    }
    
    private func setupTableView(){
        
        tableView.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tasksCell")
    }
    
    private func setupColorPicker(){
        picker.selectedColor = self.view.backgroundColor ?? #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
    }
    
    private func setupNavigationController(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Contacts", style: .done, target: self, action: #selector(didTapDismiss))
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func customiseView(){
        viewForTable.backgroundColor = .secondarySystemBackground
        viewForTable.viewForImage.backgroundColor = .systemBackground
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenPhoto))
        gesture.numberOfTapsRequired = 1
        viewForTable.addGestureRecognizer(gesture)
        
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
    
    @objc private func pushController(vc: UIViewController){
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        nav.sheetPresentationController?.detents = [.large()]
        nav.sheetPresentationController?.prefersGrabberVisible = true
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }

}

extension NewContactViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksCell", for: indexPath)
        let data = cellsName[indexPath.section][indexPath.row]
        cell.textLabel?.text = data
        cell.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = .systemBackground
        
        if indexPath == [4,0] {
            cell.backgroundColor = cellBackgroundColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellName = cellsName[indexPath.section][indexPath.row]
        switch indexPath {
        case [0,0]:
            alertTextField(cell: cellName, placeholder: "Enter title of event", table: tableView) { text in
                self.cellsName[indexPath.section][indexPath.row] = text
            }
        case [1,0]:
            alertDate(table: tableView) { weekday, date, dateString in
                self.cellsName[indexPath.section][indexPath.row] += ": " + dateString
            }
            alertTime(table: tableView) { date, time in
                self.cellsName[indexPath.section][indexPath.row] += ".Time : " + time
            }
        case [2,0]:
            alertTextField(cell: cellName, placeholder: "Enter notes value", table: tableView) { text in
                self.cellsName[indexPath.section][indexPath.row] = text
            }
        case [3,0]:
            alertTextField(cell: cellName, placeholder: "Enter URL value", table: tableView, completion: { text in
                self.cellsName[indexPath.section][indexPath.row] = text
            })
        case [4,0]:
            openColorPicker()
            
        default:
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerArray[section]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    

    
}

extension NewContactViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        cellBackgroundColor = color
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension NewContactViewController {
    private func setupConstraints(){
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(0)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(view.frame.size.height/2)
        }
        view.addSubview(viewForTable)
        viewForTable.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(180)
        }
        view.addSubview(labelForImageView)
        labelForImageView.snp.makeConstraints { make in
            make.bottom.equalTo(viewForTable.snp.top).offset(-10)
            make.height.equalTo(25)
            make.leading.equalToSuperview().offset(30)
        }
        
    }
}
