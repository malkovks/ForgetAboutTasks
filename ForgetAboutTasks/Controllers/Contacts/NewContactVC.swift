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
    
    private let headerArray = ["Name".localized()
                               ,"Main Info".localized()
                               ,"Address".localized()
                               ,"Birthday".localized()
                               ,"Type of contact".localized()]
    private var cellsName = [["Enter Name".localized()
                              , "Enter Second Name".localized()],
                             ["Enter Phone number".localized()
                              ,"Enter Mail".localized()],
                             ["Country".localized()
                              ,"City".localized()
                              ,"Address".localized()
                              ,"Postal Code".localized()],
                             ["Choose date".localized()],
                             ["Choose Type of contact".localized()]]
    private var contactModel = ContactModel()
    
    private var isStartEditing: Bool = false
    //MARK: - UI elements
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let viewForTable = NewContactCustomView()
    
    private let labelForImageView: UILabel = {
        let label = UILabel()
        label.text = "Choose image".localized()
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
        } else {
            alertError(text: "Enter value in Name and Phone sections".localized(), mainTitle: "Error saving!".localized())
        }
    }
    
    @objc private func didTapOpenPhoto(){
        alertImagePicker { [weak self] sourceType in
            self?.chooseImagePicker(source: sourceType)
        }
    }
    @objc private func didTapDismiss(){
        if isStartEditing {
            setupAlertSheet()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    //MARK: - Setup methods
    private func setupView() {
        setupNavigationController()
        setupConstraints()
        customiseView()
        view.backgroundColor = UIColor(named: "backgroundColor")
        title = "New Contact".localized()
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .done, target: self, action: #selector(didTapDismiss))
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
        
        let email = CNLabeledValue(label: CNLabelHome, value: model.contactMail as? NSString ?? "No email")
        
        let phone = String.format(with: "+X (XXX) XXX-XXXX", phone: model.contactPhoneNumber ?? "No number")
        let address = CNMutablePostalAddress()
        address.country = model.contactCountry ?? ""
        address.city = model.contactCity ?? ""
        address.street = model.contactAddress ?? ""
        address.postalCode = model.contactPostalCode ?? ""
        _ = CNLabeledValue(label: CNLabelHome, value: address)//Доделать
        
        contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: phone))]
        contact.emailAddresses = [email]
        contact.imageData = data
        contact.givenName = model.contactName ?? "No name"
        contact.familyName = model.contactSurname ?? ""
        
        
        
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        
        do {
            try store.execute(saveRequest)
        } catch {
            alertError(text: "Could not saved contact in Contacts List. Try again later".localized(), mainTitle: "Error saving!".localized())
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
            alertTextField(cell: cellName, placeholder: "Enter first name".localized(), keyboard: .default) { [unowned self] text in
                self.cellsName[indexPath.section][indexPath.row] = text
                cell?.textLabel?.text = text
                contactModel.contactName = text
                self.isStartEditing = true
            }
        case [0,1]:
            alertTextField(cell: cellName, placeholder: "Enter secon name".localized(), keyboard: .default) { [unowned self] text in
                self.cellsName[indexPath.section][indexPath.row] = text
                cell?.textLabel?.text = text
                contactModel.contactSurname = text
                self.isStartEditing = true
            }
        case [1,0]:
            alertPhoneNumber(cell: cellName, placeholder: "Enter valid number".localized(), keyboard: .numberPad) { [unowned self] text in
                self.cellsName[indexPath.section][indexPath.row] = text
                cell?.textLabel?.text = text
                contactModel.contactPhoneNumber = text
                self.isStartEditing = true
            }
        case [1,1]:
            alertTextField(cell: cellName, placeholder: "Enter mail".localized(), keyboard: .emailAddress) { [weak self] text in
                if text.emailValidation(email: text) {
                    self?.cellsName[indexPath.section][indexPath.row] = text.lowercased()
                    self?.contactModel.contactMail = text
                    cell?.textLabel?.text = text
                    self?.isStartEditing = true
                } else {
                    self?.alertError(text: "Enter the @ domain and country domain".localized(), mainTitle: "Warning!".localized())
                }
            }
        case [2,0]: alertTextField(cell: cellName, placeholder: "Enter name of country".localized(), keyboard: .default) { [weak self]  text in
            cell?.textLabel?.text = text
            self?.contactModel.contactCountry = text
            self?.isStartEditing = true
        }
        case [2,1]: alertTextField(cell: cellName, placeholder: "Enter name of city".localized(), keyboard: .default) { [weak self]  text in
            cell?.textLabel?.text = text
            self?.contactModel.contactCity = text
            self?.isStartEditing = true
        }
        case [2,2]: alertTextField(cell: cellName, placeholder: "Enter the address".localized(), keyboard: .default) { [weak self]  text in
            cell?.textLabel?.text = text
            self?.contactModel.contactAddress = text
            self?.isStartEditing = true
        }
        case [2,3]: alertTextField(cell: cellName, placeholder: "Enter postal code".localized(), keyboard: .default) { [weak self]  text in
            cell?.textLabel?.text = text
            self?.contactModel.contactPostalCode = text
            self?.isStartEditing = true
        }
        case [3,0]: alertDate( choosenDate: Date()) { [weak self] _, birthday, text in
            cell?.textLabel?.text = text
            self?.contactModel.contactDateBirthday = birthday
            self?.isStartEditing = true
        }
        case [4,0]:
            alertFriends { [ weak self] text in
                self?.cellsName[indexPath.section][indexPath.row] = text
                self?.contactModel.contactType = text
                self?.isStartEditing = true
                cell?.textLabel?.text = text
            }
        default:
            break
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
    
    private func setupAlertSheet(title: String = "Attention".localized() ,subtitle: String = "You inputed the data that was not saved.\nWhat do you want to do?".localized()) {
        let sheet = UIAlertController(title: title, message: subtitle, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Discard changes".localized(), style: .destructive,handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Save".localized(), style: .default,handler: { [self] _ in
            didTapSave()
        }))
        sheet.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(sheet, animated: true)
    }

}
