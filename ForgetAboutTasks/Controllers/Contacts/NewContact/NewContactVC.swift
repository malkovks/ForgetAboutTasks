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
    
    private let headerArray = ["Name","Phone","Mail","Type"]
    
    private var cellsName = [["Name"],
                     ["Phone number"],
                     ["Mail"],
                     ["Type of contact"]]
    
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
        alertImagePicker { sourceType in
            self.chooseImagePicker(source: sourceType)
        }
    }
    
    @objc private func didTapDismiss(){
        self.dismiss(animated: true)
    }
    
    //MARK: - Setup methods
    private func setupView() {
        setupNavigationController()
        setupConstraints()
        customiseView()
        view.backgroundColor = .secondarySystemBackground
        title = "New Contact"
    }
    
    private func setupTableView(){
        
        tableView.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tasksCell")
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellName = cellsName[indexPath.section][indexPath.row]
        switch indexPath.section {
        case 0:
            alertTextField(cell: cellName, placeholder: "Enter name of contact", table: tableView) { text in
                self.cellsName[indexPath.section][indexPath.row] = text
            }
        case 1:
            alertTextField(cell: cellName, placeholder: "Enter number of contact", table: tableView) { text in
                self.cellsName[indexPath.section][indexPath.row] = text
            }
        case 2:
            alertTextField(cell: cellName, placeholder: "Enter mail", table: tableView) { text in
                self.cellsName[indexPath.section][indexPath.row] = text
            }
        case 3:
            alertFriends(tableView: tableView) { text in
                self.cellsName[indexPath.section][indexPath.row] = text
            }
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

extension NewContactViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        viewForTable.contactImageView.image = info[.editedImage] as? UIImage
        viewForTable.contactImageView.contentMode = .scaleAspectFill
        viewForTable.contactImageView.clipsToBounds = true
        dismiss(animated: true)
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
