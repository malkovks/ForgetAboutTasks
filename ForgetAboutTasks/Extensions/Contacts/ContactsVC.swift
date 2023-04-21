//
//  ContactsViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
//

import UIKit
import SnapKit
import RealmSwift


class ContactsViewController: UIViewController {
    
    var contactData: Results<ContactModel>!
    private var localRealmData = try! Realm()
    
    private let searchController = UISearchController()
    private let tableView = UITableView()
    
    private let refreshController: UIRefreshControl = {
       let controller = UIRefreshControl()
        controller.tintColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        controller.attributedTitle = NSAttributedString(string: "Pull to refresh")
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupView()
    }

    //MARK: - Targets methods
    @objc private func didTapCreateNewContact(){
        let vc = UINavigationController(rootViewController: NewContactViewController())
        vc.isNavigationBarHidden = false
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        present(vc, animated: true)
    }
    
    @objc private func didTapRefresh(sender: AnyObject){
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshController.endRefreshing()
        }
    }
    //MARK: - Setup methods
    private func setupView() {
        setupNavigationController()
        setupConstraints()
        setupSearchController()
        loadingRealmData()
        view.backgroundColor = .secondarySystemBackground
        refreshController.addTarget(self, action: #selector(didTapRefresh), for: .valueChanged)
    }
    
    private func setupTableView(){
        view.addSubview(tableView)
        tableView.refreshControl = refreshController
        tableView.backgroundColor = .secondarySystemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "contactCell")
    }

    private func setupSearchController(){
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
    }
    
    private func setupNavigationController(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapCreateNewContact))
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Contacts"
    }
    //MARK: -Loading methods
    private func loadingRealmData(typeOf sort: String = "contactName") {
        let secValue = localRealmData.objects(ContactModel.self).sorted(byKeyPath: sort)
        contactData = secValue
        self.tableView.reloadData()
    }

}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "contactCell")
        let data = contactData[indexPath.row]
        cell.layer.cornerRadius = 10
        cell.contentView.layer.cornerRadius = 10
        cell.backgroundColor = .systemBackground
        cell.textLabel?.font = .systemFont(ofSize: 20,weight: .semibold)
        cell.accessoryType = .disclosureIndicator

        cell.imageView?.layer.cornerRadius = 0.5 * (cell.imageView?.bounds.size.width)!
        cell.imageView?.clipsToBounds = true
        cell.imageView?.frame = .zero
        if let dataImage = data.contactImage {
            cell.textLabel?.text = data.contactName
            cell.detailTextLabel?.text = "Phone number: " + data.contactPhoneNumber
            cell.imageView?.image = UIImage(data: dataImage)
        } else {
            cell.imageView?.image = UIImage(systemName: "person.crop.circle.fill")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath)
        let cellData = contactData[indexPath.row]
        let actionInstance = UIContextualAction(style: .normal, title: "") { _, _, completionHandler in
            if cell?.textLabel?.textColor == .lightGray {
                cell?.textLabel?.textColor = .black
                cell?.detailTextLabel?.textColor = .black
                cell?.imageView?.tintColor = .systemBlue
            } else {
                cell?.textLabel?.textColor = .lightGray
                cell?.imageView?.tintColor = .lightGray
                cell?.detailTextLabel?.textColor = .lightGray
            }
        }
        let detailInstance = UIContextualAction(style: .normal, title: "") { [self] _, _, handler in
            let vc = NewContactViewController()
            vc.isViewEdited = false
            vc.contactModel = cellData
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden = false
            nav.modalPresentationStyle = .pageSheet
            nav.sheetPresentationController?.prefersGrabberVisible = true
            present(nav, animated: true)
        }
        detailInstance.backgroundColor = .systemGray
        detailInstance.image = UIImage(systemName: "ellipsis")
        detailInstance.image?.withTintColor(.systemBackground)
        
        actionInstance.backgroundColor = .systemYellow
        actionInstance.image = UIImage(systemName: "pencil.line")
        actionInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [actionInstance,detailInstance])
        return action
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let model = contactData[indexPath.row]
        let deleteInstance = UIContextualAction(style: .destructive, title: "") { _, _, _ in
            ContactRealmManager.shared.deleteContactModel(model: model)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteInstance.backgroundColor = .systemRed
        deleteInstance.image = UIImage(systemName: "trash.fill")
        deleteInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [deleteInstance])
        
        return action
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellData = contactData[indexPath.row]
        let vc = NewContactViewController()
        vc.isViewEdited = false
        vc.contactModel = cellData
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = false
        nav.modalPresentationStyle = .pageSheet
        nav.sheetPresentationController?.prefersGrabberVisible = true
        present(nav, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

extension ContactsViewController {
    private func setupConstraints(){
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(0)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(0)
        }
    }
}
