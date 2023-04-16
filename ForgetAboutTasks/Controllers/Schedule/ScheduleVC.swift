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

class ScheduleViewController: UIViewController {
    
    var dateDictionary: [String: [TasksDate]] = [:]
    
    let formatter = Formatters()
    
    let localRealm = try! Realm()
    private var scheduleModel: Results<ScheduleModel>!
    
    private var calendar: FSCalendar = {
       let calendar = FSCalendar()
        calendar.scrollDirection = .vertical
        calendar.locale = Locale(identifier: "en")
        calendar.pagingEnabled = false
        calendar.weekdayHeight = 30
        calendar.headerHeight = 50
        calendar.firstWeekday = 2
        calendar.tintColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    
    
    //MARK: - Setup for views
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAuthentification()
    }
    
   //MARK: - target methods
    @objc private func didTapTapped(){
        if !calendar.pagingEnabled {
            calendar.pagingEnabled = true
            navigationItem.leftBarButtonItem?.image = UIImage(systemName: "eye.slash.fill")
            
        } else {
            calendar.pagingEnabled = false
            navigationItem.leftBarButtonItem?.image = UIImage(systemName: "eye.fill")
        }
    }

    //MARK: - Setup Methods
    private func setupDelegates(){
        calendar.delegate = self
        calendar.dataSource = self
    }
    
    private func setupAuthentification(){
        if CheckAuth.shared.isNotAuth() {
            let vc = UserAuthViewController()
            let navVC = UINavigationController(rootViewController: vc)
            navVC.modalPresentationStyle = .fullScreen
            navVC.isNavigationBarHidden = false
            present(navVC, animated: true)
        } else {
            setupView()
            setupNavigationController()
        }
    }
    
    private func setupView(){
        setupDelegates()
        setupConstraints()
        loadingRealmData()
        loadingDataByDate(date: Date(), at: .current, is: true)
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavigationController(){
        title = "Schedule"
        navigationController?.tabBarController?.tabBar.scrollEdgeAppearance = navigationController?.tabBarController?.tabBar.standardAppearance
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func loadingRealmData(){
        scheduleModel = localRealm.objects(ScheduleModel.self)
    }
    
    private func loadingDataByDate(date: Date,at monthPosition: FSCalendarMonthPosition,is firstLoad: Bool) {
        let dateStart = date
        let dateEnd: Date = {
            let components = DateComponents(day:1, second: -1)
            return Calendar.current.date(byAdding: components, to: dateStart)!
        }()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        guard let weekday = components.weekday else { alertError(text: "", mainTitle: "Error value");return }
        
        let predicate = NSPredicate(format: "scheduleWeekday = \(weekday) AND scheduleRepeat = true")
        let predicateUnrepeat = NSPredicate(format: "scheduleRepeat = false AND scheduleDate BETWEEN %@", [dateStart,dateEnd])
        let compound = NSCompoundPredicate(type: .or, subpredicates: [predicate,predicateUnrepeat])
        let value = localRealm.objects(ScheduleModel.self).filter(compound)
        scheduleModel = value
        

        if firstLoad == false {
            if monthPosition == .current {
                let vc = CreateTaskForDayController()
                vc.choosenDate = date
                vc.cellDataScheduleModel = value
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                nav.isNavigationBarHidden = false
                present(nav, animated: true)
            }
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
        print(calendar.selectedDate)
         
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        return 0
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.weekday], from: date)
//        let weekday = components.weekday
//        let predicate = NSPredicate(format: "scheduleWeekday = \(weekday ?? 0) AND scheduleRepeat = true")
//        let secondPredicate = NSPredicate(format: "scheduleWeekday = \(weekday ?? 0)")
//        scheduleModel = localRealm.objects(ScheduleModel.self).filter(predicate)
//        let valueCount = localRealm.objects(ScheduleModel.self).filter(secondPredicate).count
//        return valueCount
        
        
        
       
        
        
        /* let string = formatter.stringFromDate(date: date)
        if self.dateDictionary[string] != nil && self.dateDictionary[string]?.count == 1 {
            return 1
        } else if self.dateDictionary[string]?.count == 2 {
            return 2
        } else if let count = self.dateDictionary[string]?.count   {
            if count >= 3 {
                return 3
            }
        }
        return 0
         */
    }
}

extension ScheduleViewController: FSCalendarDelegateAppearance {
    
}

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

//MARK: - Добавление евентов в календарь для отображения
//    var dates = ["2023-03-10","2023-03-11","2023-03-12","2023-03-13","2023-03-14","2023-03-15"]
//



//    private func setupSwipeAction(){
//        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(didTapSwipe))
//        swipeUp.direction = .up
//        calendar.addGestureRecognizer(swipeUp)
//
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(didTapSwipe))
//        swipeDown.direction = .up
//        calendar.addGestureRecognizer(swipeDown)
//    }
    
//    @objc private func didTapSwipe(gesture: UISwipeGestureRecognizer){
//        switch gesture.direction {
//        case .up:
//            didTapTapped()
//        case .down:
//            didTapTapped()
//        default:
//            break
//        }
//    }

