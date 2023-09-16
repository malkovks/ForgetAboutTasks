//
//  ContactsViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
//

import UIKit
import SnapKit
import RealmSwift
import MessageUI
import Contacts
import ContactsUI


class ContactsViewController: UIViewController , CheckSuccessSaveProtocol{
    
    private var contactData: Results<ContactModel>!
    private var filteredContactData: Results<ContactModel>!
    private var localRealmData = try! Realm()
    private let contactStore = CNContactStore()
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return true }
        return text.isEmpty
    }
    
    private var viewIsFiltered: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    //MARK: - UI elements
    private let searchController = UISearchController()
    
    private let tableView = UITableView()
    
    private var actionMenu: UIMenu = UIMenu()
    
    private let refreshController: UIRefreshControl = {
        let controller = UIRefreshControl()
        controller.tintColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        controller.attributedTitle = NSAttributedString(string: "Pull to refresh".localized())
        return controller
    }()
    
    private lazy var deleteSelectedRowMenuButton: UIBarButtonItem = {
       return UIBarButtonItem(image: UIImage(systemName: "trash.circle.fill"))
    }()
    
    private lazy var importContactsButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "arrow.down.circle.fill"), style: .done, target: self, action: #selector(didTapOpenContacts))
    }()
    
    private lazy var createContactButton: UIBarButtonItem = {
       return UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .done, target: self, action: #selector(didTapCreateNewContact))
    }()
    
    private lazy var editTableViewButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEditTable))
    }()
    
    private lazy var deleteAllEventsButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "trash.circle.fill"),menu: actionMenu)
    }()
    
    private let contactPicker = CNContactPickerViewController()
//MARK: - Views loading
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationController()
        UIView.transition(with: tableView, duration: 0.3,options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
    }

    //MARK: - Targets methods
    @objc private func didTapCreateNewContact(){
        setupHapticMotion(style: .soft)
        let vc = NewContactViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: isViewAnimated)
    }
    
    @objc private func didTapOpenContacts(){
        setupHapticMotion(style: .soft)
        requestAccessForInheritContacts { [weak self] success in
            if let _ = success {
                let vc = self?.contactPicker
                let nav = UINavigationController(rootViewController: vc!)
                self?.present(nav, animated: isViewAnimated)
            }
        }
    }
    
    @objc private func didTapEditTable(){
        setupHapticMotion(style: .rigid)
        if tableView.isEditing {
            tableView.setEditing(false, animated: isViewAnimated)
            navigationItem.setRightBarButtonItems([createContactButton,importContactsButton], animated: isViewAnimated)
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            if !contactData.isEmpty {
                tableView.setEditing(true, animated: isViewAnimated)
                navigationItem.setRightBarButtonItems([deleteAllEventsButton], animated: isViewAnimated)
                navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }
    
    @objc private func didTapClearTable(){
        setupHapticMotion(style: .heavy)
        alertForDeleting()
    }
    //MARK: - Setup methods
    private func setupView() {
        isSavedCompletely(boolean: false)
        setupConstraints()
        setupSearchController()
        loadingContactData()
        contactPicker.delegate = self
        view.backgroundColor = UIColor(named: "backgroundColor")
        setupActionWithMenu()
    }
    
    private func setupTableView(){
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.separatorStyle = .singleLine
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "contactCell")
    }

    private func setupSearchController(){
        searchController.searchBar.placeholder = "Search Contacts"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    
    private func setupNavigationController(){
        navigationItem.rightBarButtonItems = [createContactButton,importContactsButton]
        navigationItem.leftBarButtonItem = editTableViewButton
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationController")
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = UIColor(named: "calendarHeaderColor")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        title = "Contacts".localized()
    }
    
    private func setupActionWithMenu(){
        let deleteAllModels = UIAction(title: "Delete all items") { [unowned self] _ in
            self.alertForDeleting()
        }
        let deleteChosenModels = UIAction(title: "Delete selected items") { [unowned self] _ in
            self.deleteChosenItems()
        }
        let closeEditingButton = UIAction(title: "End editing") { [unowned self] _ in
            self.tableView.endEditing(true)
            navigationItem.setRightBarButtonItems([createContactButton,importContactsButton], animated: isViewAnimated)
        }
        let firstSection = UIMenu(title: "Deleting actions",options: .destructive,children: [deleteAllModels,deleteChosenModels])
        let secondSection = UIMenu(title: "",options: .displayInline,children: [closeEditingButton])
        actionMenu = UIMenu(image: UIImage(systemName: "square.and.pencil.circle.fill"),children: [firstSection,secondSection])
        
    }
    
    private func deleteChosenItems(){
        tableView.beginUpdates()
        let indexes = tableView.indexPathsForSelectedRows
        if let indexes = indexes {
            for index in indexes {
                let model = contactData[index.row]
                ContactRealmManager.shared.deleteContactModel(model: model)
            }
            tableView.deleteRows(at: indexes, with: .fade)
        }
        tableView.endUpdates()
    }
    
    
    //MARK: -Loading methods
    
    /// Function for loading data from realm model
    /// - Parameter sort: type of sort contacts
    private func loadingContactData(typeOf sort: String = "contactName") {
        let secValue = localRealmData.objects(ContactModel.self).sorted(byKeyPath: sort)
        contactData = secValue
        self.tableView.reloadData()
    }
    
    
    /// Function for deleting all contacts from realm model
    private func alertForDeleting(){
        setupHapticMotion(style: .medium)
        let alert = UIAlertController(title: "Warning!".localized(),
                                      message: "Are you sure you want to delete all contacts permanently?".localized(), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete".localized(), style: .destructive,handler: { [self] _ in
            ContactRealmManager.shared.deleteAllContactModel()
            let indexPaths = (0..<tableView.numberOfRows(inSection: 0)).map { IndexPath(row: $0, section: 0) }
            tableView.deleteRows(at: indexPaths, with: .top)
            tableView.setEditing(false, animated: isViewAnimated)
            navigationItem.setRightBarButtonItems([createContactButton,importContactsButton], animated: isViewAnimated)
            navigationItem.rightBarButtonItem?.isEnabled = true
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: isViewAnimated)
    }

    
    /// Function for importing chosen contacts from system Contacts application
    /// - Parameter contacts: array of imported contacts
    private func importContact(contacts: [CNContact]){
        for contact in contacts {
            let model = ContactModel()
            
            let phone = contact.phoneNumbers.first?.value ?? CNPhoneNumber(stringValue: "")
            let email = contact.emailAddresses.first?.value
            let numberPhone = CNPhoneNumber(stringValue: phone.stringValue).stringValue
            if let birthDay = contact.birthday {
                let calendar = Calendar.current
                let dateBirthday = calendar.date(from: birthDay)
                model.contactDateBirthday = dateBirthday
            }
            
            let address = contact.postalAddresses.first?.value

            let emailString = email as? String
            
            model.contactImage = contact.imageData
            model.contactName = contact.givenName + " " + contact.middleName
            model.contactSurname = contact.familyName
            model.contactPhoneNumber = numberPhone
            model.contactMail = emailString
            model.contactCountry = address?.country ?? ""
            model.contactCity = (address?.city ?? "") + " " + (address?.subAdministrativeArea ?? "")
            model.contactAddress = address?.street ?? ""
            model.contactPostalCode = address?.postalCode ?? ""
            
            ContactRealmManager.shared.saveContactModel(model: model)
            tableView.reloadData()
            showAlertForUser(text: "Choosen contact imported successfully".localized(), duration: DispatchTime.now()+1, controllerView: view)
        }
    }
    
    
    /// Function for sharing contact vCard for any applications
    /// - Parameter indexPath: indexPath of contact in table view
    private func shareChoosenContact(indexPath: IndexPath){
        let model = viewIsFiltered ? filteredContactData[indexPath.row] : contactData[indexPath.row]
        let contact = CNMutableContact()
        let phoneNumber = [CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: model.contactPhoneNumber ?? ""))]
        let email = [CNLabeledValue(label: CNLabelWork, value: model.contactMail as? NSString ?? "")]

        contact.givenName = model.contactName ?? ""
        contact.familyName = model.contactSurname ?? ""
        contact.imageData = model.contactImage
        contact.phoneNumbers = phoneNumber
        contact.emailAddresses = email
        
        let documentaryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let fileURL = URL.init(fileURLWithPath: (documentaryPath?.appending("/My Contacts.vcf"))!)
        let data: NSData?
        do {
            try data = CNContactVCardSerialization.data(with: [contact]) as NSData
            let activity = UIActivityViewController(activityItems: [data as Any], applicationActivities: nil)
            present(activity, animated: isViewAnimated)
        } catch {
            alertError(text: "Cant share contact".localized(), mainTitle: "Warning".localized())
        }
    }
    
    
    
    /// Method for gets index of chosen contact and present Edit view controller
    /// - Parameter indexPath: chosen indexpath of table view
    private func openChoosenContact(indexPath: IndexPath){
        let model = viewIsFiltered ? filteredContactData[indexPath.row] : contactData[indexPath.row]
        let vc = EditContactViewController(contactModel: model, editing: false)
        navigationController?.pushViewController(vc, animated: isViewAnimated)
    }
    
    
    /// Method for deleting contact from realm model and from Contacts
    /// - Parameter indexPath: table view indexPath
    private func deleteChoosenContact(indexPath: IndexPath){
        tableView.beginUpdates()
        let model = viewIsFiltered ? filteredContactData : contactData
        ContactRealmManager.shared.deleteContactModel(model: (model?[indexPath.row])!)//не забыть убрать форс анреп
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
    
    /// Function for make call of chosen contact
    /// - Parameter indexPath: table view indexPath
    private func makeCallContact(indexPath: IndexPath){
        let model = viewIsFiltered ? filteredContactData[indexPath.row] : contactData[indexPath.row]
        let phone = model.contactPhoneNumber?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "No number to call"
        guard let url = URL(string: "tel://\(phone)") else { self.alertError(text: "Incorrect number");return}
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        } else {
            self.alertError(text: "This function is not avaliable.\nTry again later".localized(), mainTitle: "Error!".localized())
        }
    }
    
    
    /// Function for sending quick message to chosen contact
    /// - Parameter indexPath: table view index path
    private func makeSendMessage(indexPath: IndexPath){
        let model = viewIsFiltered ? filteredContactData[indexPath.row] : contactData[indexPath.row]
        let phone = model.contactPhoneNumber ?? "No number to call"
        if MFMessageComposeViewController.canSendText() {
            let vc = MFMessageComposeViewController()
            vc.body = "Hello!"
            vc.recipients = ["\(phone)"]
            vc.messageComposeDelegate = self
            navigationController?.pushViewController(vc, animated: isViewAnimated)
        } else {
            alertError(text: "This function is not avaliable.\nTry again later".localized(), mainTitle: "Error!".localized())
        }
    }
    
    
    /// Function for deleting selected items while table view is editing
    /// - Parameter indexPath: indexes of chosen rows in table view
    private func deleteSelectedItems(indexPath: [IndexPath]){
        
    }
    
    //delegate method
    func isSavedCompletely(boolean: Bool) {
        if boolean {
            showAlertForUser(text: "Contact saved successfully".localized(), duration: DispatchTime.now()+1, controllerView: view)
        }
    }

    
}
//MARK: - Contacts delegate
extension ContactsViewController: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        importContact(contacts: contacts)
    }
}

//MARK: - Search delegates
extension ContactsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterTable(searchController.searchBar.text ?? "Empty value")
    }
    
    private func filterTable(_ searchText: String) {
        filteredContactData = contactData.filter("contactName CONTAINS[c] %@ OR contactSurname CONTAINS[c] %@ OR contactPhoneNumber CONTAINS[c] %@",searchText,searchText,searchText)
        tableView.reloadData()
    }

    
}
//MARK: - Table view delegates
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewIsFiltered ? filteredContactData.count : contactData.count)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = contactData[indexPath.row]
            tableView.deleteRows(at: [indexPath], with: .fade)
            try! localRealmData.write({
                localRealmData.delete(contact)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions in
            let shareAction = UIAction(title: NSLocalizedString("Share Contact Card".localized(), comment: ""), image: UIImage(systemName: "square.and.arrow.up.circle.fill")) { [ weak self] _ in
                self?.shareChoosenContact(indexPath: indexPath)
                
            }
            let openAction = UIAction(title: NSLocalizedString("Open Contact".localized(), comment: ""),image: UIImage(systemName: "info.circle.fill")) { [unowned self] action in
                self.openChoosenContact(indexPath: indexPath)
            }
            let callAction = UIAction(title: NSLocalizedString("Call to contact".localized(), comment: ""),image: UIImage(systemName: "phone.fill")) { [unowned self] _ in
                self.makeCallContact(indexPath: indexPath)
            }
            let messageAction = UIAction(title: NSLocalizedString("Send message".localized(), comment: ""),image: UIImage(systemName: "message.fill")) { [unowned self] _ in
                self.makeSendMessage(indexPath: indexPath)
            }
            let deleteAction = UIAction(title: NSLocalizedString("Delete Contact".localized(), comment: ""),image: UIImage(systemName: "trash"),attributes: .destructive) { [unowned self] _ in
                self.deleteChoosenContact(indexPath: indexPath)
            }
            return UIMenu(title: "", children: [shareAction,callAction,messageAction,openAction,deleteAction])
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "contactCell")
        let data = (viewIsFiltered ? filteredContactData[indexPath.row] : contactData[indexPath.row])

        cell.backgroundColor = UIColor(named: "backgroundColor")
        
        cell.accessoryType = .disclosureIndicator

        cell.imageView?.clipsToBounds = true
        cell.imageView?.frame = .zero
        cell.imageView?.contentMode = .scaleToFill
        cell.imageView?.tintColor = UIColor(named: "calendarHeaderColor")
        let number = data.contactPhoneNumber ?? "No phone number"

        cell.textLabel?.text = (data.contactName ?? "") + " " + (data.contactSurname ?? "")
        cell.textLabel?.font = .setMainLabelFont()
        cell.detailTextLabel?.font = .setDetailLabelFont()
        cell.detailTextLabel?.text = "Phone number: ".localized() + (number)
        cell.imageView?.image = UIImage(systemName: "person.crop.circle.fill")
        cell.imageView?.frame(forAlignmentRect: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let detailInstance = UIContextualAction(style: .normal, title: "") { [weak self] _, _, handler in
            self?.openChoosenContact(indexPath: indexPath)
        }
        detailInstance.backgroundColor = .lightGray
        detailInstance.image = UIImage(systemName: "ellipsis")
        detailInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [detailInstance])
        return action
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteInstance = UIContextualAction(style: .destructive, title: "") { [unowned self] _, _, _ in
            self.deleteChoosenContact(indexPath: indexPath)
        }
        deleteInstance.backgroundColor = .systemRed
        deleteInstance.image = UIImage(systemName: "trash.fill")
        deleteInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [deleteInstance])
        
        return action
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: isViewAnimated)
            openChoosenContact(indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        fontSizeValue * 4
    }
}
//MARK: - Message delegate for opening mail
extension ContactsViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if result == .cancelled {
            self.dismiss(animated: isViewAnimated)
        }
    }
    
    
}
//MARK: - setup constraints
extension ContactsViewController {
        private func setupConstraints(){
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(0)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension Results where Element: ContactModel {
    func filterModel() -> [ContactModel]{
        var model = Set<String>()
        return compactMap { contact in
            let name = contact.contactName ?? ""
            let secondName = contact.contactSurname ?? ""
            let fullName = "\(name) \(secondName)"
            guard !model.contains(fullName) else { return nil }
            model.insert(fullName)
            return contact
        }
    }
}
