//
//  NewContactViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 06.04.2023.
//

import UIKit
import SnapKit
import MessageUI
import Contacts

class NewContactViewController: UIViewController{

    weak var delegate: CheckSuccessSaveProtocol?
    
    private let headerArray = ["Name","Main Data","Address","Birthday","Type of contact"]
    private var cellsName = [["Enter Name", "Enter Second Name"],
                             ["Enter Phone number","Enter Mail"],
                             ["Country","City","Address","Postal Code"],
                             ["Choose date"],
                             ["Choose Type of contact"]]
    private var contactModel = ContactModel()
    //MARK: - UI elements
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let viewForTable = NewContactCustomView()
    
    private let labelForImageView: UILabel = {
        let label = UILabel()
        label.text = "Choose image"
        let attributedText2 = NSAttributedString(string: label.text ?? "", attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue])
        label.attributedText = attributedText2
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
        if  let name = contactModel.contactName, let phone = contactModel.contactPhoneNumber,
            !name.isEmpty && !phone.isEmpty {
            ContactRealmManager.shared.saveContactModel(model: contactModel)
            saveContactInContacts(model: contactModel)
            contactModel = ContactModel()
            delegate?.isSavedCompletely(boolean: true)
            
            navigationController?.popViewController(animated: true)
            print("Contact was saved successfully")
        } else {
            alertError(text: "Enter value in Name and Phone sections", mainTitle: "Error saving!")
        }
    }
    
    @objc private func didTapOpenPhoto(){
        alertImagePicker { [weak self] sourceType in
            self?.chooseImagePicker(source: sourceType)
        }
    }
    //MARK: - Setup methods
    private func setupView() {
        setupNavigationController()
        setupConstraints()
        customiseView()
        view.backgroundColor = UIColor(named: "backgroundColor")
        title = "New Contact"
    }
    
    private func setupTableView(){
        tableView.isScrollEnabled = true
        tableView.bounces = true
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tasksCell")
    }
    
    private func setupNavigationController(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func customiseView(){
        viewForTable.backgroundColor = .clear
        viewForTable.viewForImage.backgroundColor = .clear
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapOpenPhoto))
        gesture.numberOfTapsRequired = 1
        viewForTable.addGestureRecognizer(gesture)
    }
    
    private func saveContactInContacts(model: ContactModel){
        let contact = CNMutableContact()
        
        guard let data = model.contactImage else { return }
        contact.imageData = data
        contact.givenName = model.contactName ?? "No name"
        let email = CNLabeledValue(label: CNLabelHome, value: model.contactMail as? NSString ?? "No email")
        contact.emailAddresses = [email]
        let phone = String.format(with: "+X (XXX) XXX-XXXX", phone: model.contactPhoneNumber ?? "No number")
        contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: phone))]
        
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        
        do {
            try store.execute(saveRequest)
        } catch {
            alertError(text: "Could not saved contact in Contacts List. Try again later", mainTitle: "Error saving!")
        }
        
    }
    

}
    //MARK: - Segue methods
extension NewContactViewController: MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension NewContactViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 2
        case 2: return 4
        case 3: return 1
        case 4: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tasksCell", for: indexPath)
        let data = cellsName[indexPath.section][indexPath.row]
        cell.backgroundColor = UIColor(named: "cellColor")
        cell.textLabel?.text = data
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        let cellName = cellsName[indexPath.section][indexPath.row]
        switch indexPath{
        case [0,0]:
            alertTextField(cell: cellName, placeholder: "Enter first name", keyboard: .default) { [unowned self] text in
                self.cellsName[indexPath.section][indexPath.row] = text
                cell?.textLabel?.text = text
                contactModel.contactName = text
            }
        case [0,1]:
            alertTextField(cell: cellName, placeholder: "Enter secon name", keyboard: .default) { [unowned self] text in
                self.cellsName[indexPath.section][indexPath.row] = text
                cell?.textLabel?.text = text
                contactModel.contactSurname = text
            }
        case [1,0]:
            alertPhoneNumber(cell: cellName, placeholder: "Enter valid number", keyboard: .numberPad) { [unowned self] text in
                self.cellsName[indexPath.section][indexPath.row] = text
                cell?.textLabel?.text = text
                contactModel.contactPhoneNumber = text
            }
        case [1,1]:
            alertTextField(cell: cellName, placeholder: "Enter mail", keyboard: .emailAddress) { [weak self] text in
                if text.emailValidation(email: text) {
                    self?.cellsName[indexPath.section][indexPath.row] = text.lowercased()
                    self?.contactModel.contactMail = text
                    cell?.textLabel?.text = text
                } else {
                    self?.alertError(text: "Enter the @ domain and country domain", mainTitle: "Warning")
                }
            }
        case [2,0]: alertTextField(cell: cellName, placeholder: "Enter name of country", keyboard: .default) { [weak self]  text in
            cell?.textLabel?.text = text
            self?.contactModel.contactCountry = text
        }
        case [2,1]: alertTextField(cell: cellName, placeholder: "Enter name of city", keyboard: .default) { [weak self]  text in
            cell?.textLabel?.text = text
            self?.contactModel.contactCity = text
        }
        case [2,2]: alertTextField(cell: cellName, placeholder: "Enter the address", keyboard: .default) { [weak self]  text in
            cell?.textLabel?.text = text
            self?.contactModel.contactAddress = text
        }
        case [2,3]: alertTextField(cell: cellName, placeholder: "Enter postal code", keyboard: .default) { [weak self]  text in
            cell?.textLabel?.text = text
            self?.contactModel.contactPostalCode = text
        }
        case [3,0]: alertDate( choosenDate: Date()) { [weak self] _, birthday, text in
            cell?.textLabel?.text = text
            self?.contactModel.contactDateBirthday = birthday
        }
        case [4,0]:
            alertFriends { [ weak self] text in
                self?.cellsName[indexPath.section][indexPath.row] = text
                self?.contactModel.contactType = text
                cell?.textLabel?.text = text
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
        let image = info[.editedImage] as? UIImage
        viewForTable.contactImageView.image = image
        viewForTable.contactImageView.contentMode = .scaleAspectFill
        viewForTable.contactImageView.clipsToBounds = true
        viewForTable.contactImageView.layer.cornerRadius = viewForTable.contactImageView.frame.size.width/2
        let finalEditImage = viewForTable.contactImageView.image
        guard let data = finalEditImage?.jpegData(compressionQuality: 1.0) else { return }
        contactModel.contactImage = data
        dismiss(animated: true)
    }
}



extension NewContactViewController {
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
