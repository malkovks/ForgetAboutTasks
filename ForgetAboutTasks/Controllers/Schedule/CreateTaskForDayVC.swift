//
//  TasksViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.03.2023.
//

import UIKit
import FSCalendar
import SnapKit
import RealmSwift


class CreateTaskForDayController: UIViewController {
    
    private var cellDataScheduleModel: Results<ScheduleModel>!
    private var localRealmData = try! Realm()
    private var choosenDate = Date()
    private var isValueWasChanged = Bool()
    private var isTrailingSwipeActionActive = Bool()
    private var indexOfCell = Int()
    private var isCellEdited = Bool()
    
    init(model: Results<ScheduleModel>,choosenDate: Date){
        self.cellDataScheduleModel = model
        self.choosenDate = choosenDate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup UI elements

    private var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.formatter.timeZone = TimeZone.current
        calendar.scrollDirection = .vertical
        calendar.appearance.todayColor = UIColor(named: "calendarHeaderColor")
        
        calendar.scope = .week
        calendar.firstWeekday = 2
        calendar.weekdayHeight = 20
        calendar.headerHeight = 30
        calendar.pagingEnabled = true
        calendar.tintColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        calendar.locale = .current
        
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 18)
        
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 20)
        calendar.appearance.borderDefaultColor = .clear
        calendar.appearance.titleWeekendColor = #colorLiteral(red: 0.3826281726, green: 0.4247716069, blue: 0.4593068957, alpha: 0.916589598)
        calendar.appearance.titleDefaultColor = UIColor(named: "textColor")
        calendar.appearance.weekdayTextColor = UIColor(named: "calendarHeaderColor")
        calendar.appearance.headerTitleColor = UIColor(named: "calendarHeaderColor")
        calendar.tintColor = UIColor(named: "navigationControllerColor")
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private var segmentalController: UISegmentedControl = {
        let controller = UISegmentedControl(items: ["Time","Date","A-Z"])
        controller.tintColor = UIColor(named: "navigationControllerColor")
        controller.backgroundColor = UIColor(named: "navigationControllerColor")
        controller.selectedSegmentIndex = 0
        controller.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    //MARK: - override views
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        calendar.reloadData()
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationController()
        setupTableViewAndDelegates()
        setupConstraintsForCalendar()
    }

 //MARK: -  actions targets methods
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    @objc private func didTapCreate(){
        let vc = CreateEventScheduleViewController(choosenDate: choosenDate)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalTransitionStyle = .flipHorizontal
        navVC.modalPresentationStyle = .fullScreen
        navVC.isNavigationBarHidden = false
        present(navVC, animated: true)
    }
    
    @objc private func didTapSegmentChanged(segment: UISegmentedControl) {
        let predicate = setupRealmData(date: choosenDate)
        if segment.selectedSegmentIndex == 0 {
            loadingRealmData(predicate: predicate, typeOf: "scheduleTime")
        } else if segment.selectedSegmentIndex == 1 {
            loadingRealmData(predicate: predicate, typeOf: "scheduleDate")
        } else if segment.selectedSegmentIndex == 2 {
            loadingRealmData(predicate: predicate, typeOf: "scheduleName")
        }
    }
//MARK: - Setups for view controller
    private func setupAlertSheet(title: String,subtitle: String) {
        let sheet = UIAlertController(title: title, message: subtitle, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Discard changes", style: .destructive,handler: { _ in
            self.dismiss(animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Save", style: .default,handler: { [self] _ in
            self.dismiss(animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
    
    private func setupGestureForDismiss(){
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didTapDismiss))
        gesture.direction = .right
        view.addGestureRecognizer(gesture)
    }
    
    private func setupView(){
        view.backgroundColor = UIColor(named: "backgroundColor")
        calendar.today =  choosenDate
        segmentalController.addTarget(self, action: #selector(didTapSegmentChanged(segment:)), for: .valueChanged)
        calendar.reloadData()
        setupGestureForDismiss()
        setupTitleView(date: choosenDate)
        
    }
    
    private func setupTableViewAndDelegates(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.register(UITableViewCell.self
                           , forCellReuseIdentifier: "cell")
        calendar.delegate = self
        calendar.dataSource = self
    }
    
    
    private func setupNavigationController(){
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapDismiss))
        let firstBut = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapCreate))
        navigationItem.rightBarButtonItems = [firstBut]
        navigationController?.navigationBar.tintColor = UIColor(named: "navigationControllerColor")
    }
    
    private func setupTitleView(date: Date){
        let convertDate = Formatters.instance.stringFromDate(date: date)
        title = "Задачи на \(convertDate)"
    }
    
    //MARK: - logics methods
    private func setupRealmData(date: Date) -> NSCompoundPredicate {
        let dateStart = date
        let dateEnd: Date = {
            let components = DateComponents(day:1, second: -1)
            return Calendar.current.date(byAdding: components, to: dateStart)!
        }()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        let weekday = components.weekday ?? 1
        let predicate = NSPredicate(format: "scheduleWeekday = \(weekday) AND scheduleRepeat = true")
        let predicateUnrepeat = NSPredicate(format: "scheduleRepeat = false AND scheduleDate BETWEEN %@", [dateStart,dateEnd])
        let compound = NSCompoundPredicate(type: .or, subpredicates: [predicate,predicateUnrepeat])
        return compound
        
    }
    
    private func loadingRealmData(predicate compound: NSCompoundPredicate,typeOf sort: String = "scheduleTime") {
        let value = localRealmData.objects(ScheduleModel.self)
            .filter(compound)
            .sorted(byKeyPath: sort)
        cellDataScheduleModel = value
        self.tableView.reloadData()
        self.calendar.reloadData()
    }
}
//MARK: - table delegates and datasource
extension CreateTaskForDayController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellDataScheduleModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(named: "backgroundColor")
        let data = cellDataScheduleModel[indexPath.row]
        
        let color = UIColor.color(withData: data.scheduleColor!) ?? #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        
        if let date = data.scheduleDate, let time = data.scheduleTime {
            let date = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            let time = Formatters.instance.timeStringFromDate(date: time)
            cell.textLabel?.text = data.scheduleName
            cell.detailTextLabel?.text = date + ". Time: " + time
            cell.imageView?.image = UIImage(systemName: "circle.fill")
            cell.imageView?.tintColor = color
        } else {
            alertError(mainTitle: "Error time or date.\nTry again!")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = cellDataScheduleModel[indexPath.row]
        let vc = OpenTaskDetailViewController(model: data)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editingData = cellDataScheduleModel[indexPath.row]
        let deleteInstance = UIContextualAction(style: .destructive, title: "") { _, _, _ in
            ScheduleRealmManager.shared.deleteScheduleModel(model: editingData)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteInstance.backgroundColor = .systemRed
        deleteInstance.image = UIImage(systemName: "trash.fill")
        deleteInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [deleteInstance])
        
        return action
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        isTrailingSwipeActionActive = true
        let cellData = cellDataScheduleModel[indexPath.row]
        let colorCell = UIColor.color(withData: cellData.scheduleColor!) ?? #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)

        let actionInstance = UIContextualAction(style: .normal, title: "") { [weak self] _, _, completionHandler in
            guard let date = self?.choosenDate else { return }
            let vc = EditEventScheduleViewController(cellBackgroundColor: colorCell, choosenDate: date, scheduleModel: cellData)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.isNavigationBarHidden = false
            self?.present(nav, animated: true)
            self?.isTrailingSwipeActionActive = false
        }
        actionInstance.backgroundColor = .systemYellow
        actionInstance.image = UIImage(systemName: "pencil.line")
        actionInstance.image?.withTintColor(.systemBackground)
        let action = UISwipeActionsConfiguration(actions: [actionInstance])
        
        return action
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        isTrailingSwipeActionActive = false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

//MARK: - calendar delegates
extension CreateTaskForDayController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        choosenDate = date
        setupTitleView(date: date)
        let predicate = setupRealmData(date: date)
        loadingRealmData(predicate: predicate)
    }
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { make in
            make.height.equalTo(bounds.height)
        }
        self.view.layoutIfNeeded()
    }
}
//MARK: - constrain extension for dymanic height changing.NOT USING
extension CreateTaskForDayController {
    private func setupConstraintsForCalendar(){
        view.addSubview(calendar)
        calendar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.frame.size.height/4+view.frame.size.height/8)
        }
        
        view.addSubview(segmentalController)
        segmentalController.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(5)
            make.height.equalTo(40)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentalController.snp.bottom).offset(5)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
