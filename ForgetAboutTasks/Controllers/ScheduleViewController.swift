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

class ScheduleViewController: UIViewController {
    
    private var calendar: FSCalendar = {
       let calendar = FSCalendar()
        calendar.scrollDirection = .vertical
        calendar.pagingEnabled = false
        calendar.weekdayHeight = 30
        calendar.headerHeight = 50
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private let hideButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Calendar", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.04713427275, green: 0.08930709213, blue: 0.1346856952, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir Next Demi Bold", size: 16)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationController()

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendar.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    @objc private func didTapTapped(){
        if !calendar.pagingEnabled {
            calendar.pagingEnabled = true
            navigationItem.leftBarButtonItem?.image = UIImage(systemName: "eye.slash.fill")
        } else {
            calendar.pagingEnabled = false
            navigationItem.leftBarButtonItem?.image = UIImage(systemName: "eye.fill")
        }
    }
    

    
    private func setupView(){
        setupTarget()
        view.addSubview(calendar)
        calendar.delegate = self
        calendar.dataSource = self
        view.backgroundColor = .systemBackground
    }
    
    private func setupTarget(){
        
    }
    
    private func setupNavigationController(){
        title = "Schedule"
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "eye.fill"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapTapped))
    }
    

    
}
//MARK: - calendar delegates
extension ScheduleViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.frame.size.height = bounds.height
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(date)
    }
    
}


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

