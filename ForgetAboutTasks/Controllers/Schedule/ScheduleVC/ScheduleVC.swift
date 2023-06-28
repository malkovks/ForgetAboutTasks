//
//  ScheduleViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
/*
 class with displaying calendar and some events
 */

import UIKit
import FSCalendar
import EventKit
import SnapKit
import RealmSwift
import WidgetKit

class ScheduleViewController: UIViewController, CheckSuccessSaveProtocol{
    
    private let localRealm = try! Realm()
    private var scheduleModel: Results<ScheduleModel>!
    private var filteredModel: Results<ScheduleModel>!
    
    //MARK: - UI elements setups
    private lazy var searchNavigationButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "magnifyingglass.circle.fill"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(didTapSearch))
    }()
    
    private lazy var createNewEventNavigationButton: UIBarButtonItem = {
        return UIBarButtonItem(title: nil, image: UIImage(systemName: "plus.circle.fill"), target: self, action: #selector(didTapCreate))
    }()
    
    private lazy var displayAllEvent: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(systemName: "list.bullet.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapOpenAllEvent))
    }()
    
    private var calendar: FSCalendar = {
       let calendar = FSCalendar()
        calendar.formatter.timeZone = TimeZone.current
        calendar.scrollDirection = .vertical
        calendar.backgroundColor = UIColor(named: "backgroundColor")
        calendar.tintColor = UIColor(named: "navigationControllerColor")
        calendar.locale = .current
        calendar.pagingEnabled = false
        calendar.weekdayHeight = 30
        calendar.headerHeight = 50
        calendar.firstWeekday = 2
        calendar.placeholderType = .none //remove past and future dates of months
        calendar.appearance.eventDefaultColor = #colorLiteral(red: 0.8374214172, green: 0.8374213576, blue: 0.8374213576, alpha: 1)
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 18)
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 20)
        calendar.appearance.borderDefaultColor = .clear
        calendar.appearance.titleWeekendColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        calendar.appearance.titleDefaultColor = UIColor(named: "textColor")
        calendar.appearance.weekdayTextColor = UIColor(named: "calendarHeaderColor")
        calendar.appearance.headerTitleColor = UIColor(named: "calendarHeaderColor")
        calendar.tintColor = UIColor(named: "navigationControllerColor")
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private let searchController: UISearchController = {
       let search = UISearchController(searchResultsController: ScheduleSearchResultViewController())
        search.searchBar.placeholder = "Enter the name of event".localized()
        search.isActive = false
        search.searchBar.searchTextField.clearButtonMode = .whileEditing
        search.obscuresBackgroundDuringPresentation = false
        return search
    }()
    
    //MARK: - Setup for views
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAuthentification()
        calendar.transform = CGAffineTransform(translationX: 0.01, y: 0.01)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendar.reloadData()
        setupAnimation()
    }
    
   //MARK: - target methods
    @objc private func didTapSearch(){
            navigationItem.searchController = searchController
            searchController.isActive = true
    }
    
    @objc private func didTapCreate(){
        let vc = CreateEventScheduleViewController(choosenDate: Date())
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .flipHorizontal
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    @objc private func didTapOpenAllEvent(){
        let vc = ScheduleAllEventViewController(model: scheduleModel)
        show(vc, sender: nil)
    }
    
    //MARK: - Setup Methods
    private func setupDelegates(){
        calendar.delegate = self
        calendar.dataSource = self
    }
    
    private func setupAnimation(){
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear) {
            self.calendar.transform = CGAffineTransform.identity
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupAuthentification(){
        if CheckAuth.shared.isNotAuth() {
            let vc = UserAuthViewController()
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            navVC.isNavigationBarHidden = false
            present(navVC, animated: true)
            setupView()
            setupNavigationController()
        } else {
            setupView()
            setupNavigationController()
        }
    }
    
    private func setupView(){
        isSavedCompletely(boolean: false)
        calendar.reloadData()
        setupDelegates()
        setupConstraints()
        setupSearchController()
        loadingData()

        loadingDataByDate(date: Date(), at: .current, is: true)
        view.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    private func setupNavigationController(){
        title = "Calendar".localized()
        navigationItem.leftBarButtonItem = searchNavigationButton
        navigationItem.rightBarButtonItems = [createNewEventNavigationButton,displayAllEvent]
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
        navigationController?.tabBarController?.tabBar.scrollEdgeAppearance = navigationController?.tabBarController?.tabBar.standardAppearance
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupSearchController(){
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = nil
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func loadingData(){
        let value = localRealm.objects(ScheduleModel.self)
        filteredModel = value
    }
    
    private func loadingDataByDate(date: Date,at monthPosition: FSCalendarMonthPosition,is firstLoad: Bool) {
        let dateStart = date
        let dateEnd: Date = {
            let components = DateComponents(day:1, second: -1)
            return Calendar.current.date(byAdding: components, to: dateStart)!
        }()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        guard let weekday = components.weekday else {
            alertError(text: "Can't get weekday numbers. Try again!".localized(), mainTitle: "Error value".localized())
            return
        }
        
        
        let value = localRealm.objects(ScheduleModel.self)
        scheduleModel = value
        let userDefaults = UserDefaults(suiteName: "group.widgetGroupIdentifier")
    
        let currentDatePredicate = NSPredicate(format: "scheduleStartDate BETWEEN %@", [dateStart,dateEnd])
        let filteredValue = localRealm.objects(ScheduleModel.self).filter(currentDatePredicate)
        userDefaults?.setValue(filteredValue.count, forKey: "group.integer")
        WidgetCenter.shared.reloadAllTimelines()
        
        if firstLoad == false {
            if monthPosition == .current {
                let predicate = NSPredicate(format: "scheduleWeekday = \(weekday)")
                let predicateUnrepeat = NSPredicate(format: "scheduleStartDate BETWEEN %@", [dateStart,dateEnd])
                let compound = NSCompoundPredicate(type: .or, subpredicates: [predicate,predicateUnrepeat])
                let value = localRealm.objects(ScheduleModel.self).filter(compound)
                let vc = CreateTaskForDayController(model: value, choosenDate: date)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                nav.isNavigationBarHidden = false
                present(nav, animated: true)
            }
        }
    }
    
    func isSavedCompletely(boolean: Bool) {
        if boolean {
            showAlertForUser(text: "Event saved successfully".localized(), duration: DispatchTime.now()+1, controllerView: view)
            loadingData()
        }
    }
}
//MARK: - calendar delegates
extension ScheduleViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { make in
            make.height.equalTo(bounds.height)
        }
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        loadingDataByDate(date: date, at: monthPosition, is: false)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var eventCounts = [String: Int]()
        
        for event in scheduleModel {
            let dateModel = event.scheduleStartDate ?? Date()
            let date = DateFormatter.localizedString(from: dateModel, dateStyle: .medium, timeStyle: .none)
            if eventCounts[date] != nil {
                eventCounts[date]! += 1
            } else {
                eventCounts[date] = 1
            }
        }

        let convertDate = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        calendar.appearance.eventDefaultColor = .systemBlue
        if eventCounts[convertDate] != nil {
            return 1
        } else {
            return 0
        }
    }
    
    
    
}
//MARK: - Search delegates
extension ScheduleViewController: UISearchResultsUpdating,UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { alertError();return }
        let value = filterTable(text)
        if !text.isEmpty {
            let vc = searchController.searchResultsController as? ScheduleSearchResultViewController
            vc?.scheduleModel = value
            vc?.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchController.isActive = false
    }

    func filterTable(_ text: String) -> Results<ScheduleModel>{
        loadingData()
        let predicate = NSPredicate(format: "scheduleName CONTAINS[c] %@", text)
        filteredModel = filteredModel.filter(predicate).sorted(byKeyPath: "scheduleStartDate")
        return filteredModel ?? scheduleModel
    }
}

//MARK: - extensions with contstraints setups
extension ScheduleViewController {
    private func setupConstraints(){
        view.addSubview(calendar)
        calendar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
            make.leading.trailing.equalToSuperview().inset(0)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(0)
        }
    }
}

