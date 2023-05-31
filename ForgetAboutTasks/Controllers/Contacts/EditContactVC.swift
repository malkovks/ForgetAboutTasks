//
//  EditContactViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 31.05.2023.
//

import UIKit
import MessageUI
import SnapKit

class EditContactViewController: UIViewController {
    
    private let headerArray = ["Name","Phone","Mail","Type"]
    
    private var cellsName = [["Name"],
                             ["Phone number"],
                             ["Mail"],
                             ["Type of contact"]]
    
    private var contactModel: ContactModel
    private var editedContactModel: ContactModel?
    private var isViewEdited: Bool
    
    init(contactModel: ContactModel,editing: Bool){
        self.contactModel = contactModel
        self.isViewEdited = editing
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI elements
    
    private let tableView = UITableView()
    private let viewForTable = NewContactCustomView()
    
    private let labelForImageView: UILabel = {
        let label = UILabel()
        label.text = "Choose image"
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
        if let name = editedContactModel?.contactName,
           let phoneNumber = editedContactModel?.contactPhoneNumber,
            name.isEmpty && phoneNumber.isEmpty {
                let filterNumber = contactModel.contactPhoneNumber
                ContactRealmManager.shared.editAllTasksModel(filter: filterNumber, newModel: editedContactModel ?? contactModel)
                navigationController?.popViewController(animated: true)
            } else {
                alertError(text: "Error editing model. Try again!", mainTitle: "Error")
        }
    }
    
    @objc private func didTapOpenPhoto(){
        alertImagePicker { [weak self] sourceType in
            self?.chooseImagePicker(source: sourceType)
        }
    }
    
    @objc private func didTapEdit(){
        isViewEdited = !isViewEdited
        setupSelection(boolean: isViewEdited)
    }

    //MARK: - Setup methods
    private func setupView() {
        setupNavigationController()
        setupConstraints()
        customiseView()
        setupSelection(boolean: isViewEdited)
        view.backgroundColor = UIColor(named: "backgroundColor")
        title = "New Contact"
    }
    
    private func setupTableView(){
        tableView.isScrollEnabled = false
        tableView.bounces = false
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tasksCell")
    }
    
    private func setupSelection(boolean: Bool){
        if !boolean {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEdit))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        }
    }
    
    private func setupNavigationController(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapSave))
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func customiseView(){
        viewForTable.backgroundColor = .clear
        viewForTable.viewForImage.backgroundColor = .clear
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenPhoto))
        gesture.numberOfTapsRequired = 1
        if isViewEdited {
            viewForTable.addGestureRecognizer(gesture)
        }
    }
    
    private func setupComposeView(model: ContactModel){
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            
            vc.setToRecipients([model.contactMail])
            vc.setSubject("Hello from Developers, \(model.contactName)")
            vc.setMessageBody("Hello \(model.contactName)", isHTML: false)
            
            self.present(vc, animated: true)
        } else {
            alertError(text: "Error sending mail")
        }
        
    }
}
    //MARK: - Segue methods
extension EditContactViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension EditContactViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksCell", for: indexPath)
        let data = cellsName[indexPath.section][indexPath.row]
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor(named: "cellColor")
        if !isViewEdited {
            if let image = contactModel.contactImage {
                viewForTable.contactImageView.image = UIImage(data: image)
                viewForTable.contactImageView.layer.cornerRadius = viewForTable.contactImageView.frame.size.width/2
                viewForTable.contactImageView.contentMode = .scaleAspectFit
                viewForTable.contactImageView.clipsToBounds = true
                labelForImageView.isHidden = true
            }
            switch indexPath {
            case [0,0]:
                cell.textLabel?.text = contactModel.contactName
            case [1,0]:
                let phoneNumber = String.format(with: "+X (XXX) XXX-XXXX", phone: contactModel.contactPhoneNumber)
                cell.textLabel?.text = phoneNumber
            case [2,0]:
                cell.textLabel?.text = contactModel.contactMail
            case [3,0]:
                cell.textLabel?.text = contactModel.contactType
            default:
                print("Error")
            }
        } else {
            cell.textLabel?.text = data
            labelForImageView.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellName = cellsName[indexPath.section][indexPath.row]
        if isViewEdited {
            switch indexPath.section {
            case 0:
                alertTextField(cell: cellName, placeholder: "Enter name of contact", keyboard: .default, table: tableView) { [unowned self] text in
                    self.cellsName[indexPath.section][indexPath.row] = text
                    contactModel.contactName = text
                }
            case 1:
                alertTextField(cell: cellName, placeholder: "Enter number of contact", keyboard: .numberPad, table: tableView) { [unowned self] text in
                    self.cellsName[indexPath.section][indexPath.row] = text
                    contactModel.contactPhoneNumber = text
                }
            case 2:
                alertTextField(cell: cellName, placeholder: "Enter mail", keyboard: .emailAddress, table: tableView) { [weak self] text in
                    if text.isEmailValid() {
                        self?.cellsName[indexPath.section][indexPath.row] = text.lowercased()
                        self?.contactModel.contactMail = text
                    } else {
                        self?.alertError(text: "Enter the @ domain and country domain", mainTitle: "Warning")
                    }
                }
            case 3:
                alertFriends(tableView: tableView) { [ weak self] text in
                    self?.cellsName[indexPath.section][indexPath.row] = text
                    self?.contactModel.contactType = text
                }
            default:
                print("error")
            }
        } else {
            switch indexPath.section {
            case 1:
                guard let url = URL(string: "tel://\(contactModel.contactPhoneNumber)") else { self.alertError();return}
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.open(url)
                } else {
                    alertError(text: "", mainTitle: "Can't call to user!")
                }
            case 2:
                setupComposeView(model: contactModel)
            default:
                print("Error")
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerArray[section]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension EditContactViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
        let image = info[.editedImage] as? UIImage
        viewForTable.contactImageView.image = image
        viewForTable.contactImageView.contentMode = .scaleAspectFill
        viewForTable.contactImageView.clipsToBounds = true
        viewForTable.contactImageView.layer.cornerRadius = viewForTable.contactImageView.frame.size.width/2
        let finalEditImage = viewForTable.contactImageView.image
        guard let data = finalEditImage?.pngData() else { print("Error converting"); return }
        print("Data was saved successfully")
        contactModel.contactImage = data
        dismiss(animated: true)
    }
}



extension EditContactViewController {
    private func setupConstraints(){
        
        view.addSubview(viewForTable)
        viewForTable.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.height.width.equalTo(180)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(labelForImageView)
        labelForImageView.snp.makeConstraints { make in
            make.top.equalTo(viewForTable.snp.bottom).offset(10)
            make.height.equalTo(25)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(labelForImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(10)
        }
        
    }
}
