//
//  MainViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 08.03.2023.
//

import UIKit
import EventKit
import EventKitUI

class MainViewController: UIViewController {
    
    
    private let store = EKEventStore()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .secondarySystemBackground
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.requestAccess(to: .event) { success, error in
            if success, error == nil {
                DispatchQueue.main.async {
                    self.setupView()
                }
            } else {
                let alert = UIAlertController(title: "Warning", message: "Please give access to calendar", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc private func didTapNewRemind(){
        let event = EKEvent(eventStore: self.store)
//        let vc = EKCalendarChooser()
//        vc.showsDoneButton = true
//        vc.showsCancelButton = true
//        present(UINavigationController(rootViewController: vc), animated: true)
//

        
        event.title = "Check EKEvent"
        event.startDate = Date()
        event.endDate = Date()+1
//
        let otherVC = EKEventEditViewController()
        otherVC.eventStore = store
        otherVC.event = event
        otherVC.editViewDelegate = self
        self.present(otherVC, animated: true)

//        let vc = EKEventViewController()
//        vc.delegate = self
//        vc.event = event
//        let nav = UINavigationController(rootViewController: vc)
//        self.present(nav, animated: true)
    }
    
    @objc private func didTapOpenWeekCalendar(){
        let vc = CalendarViewController()
        vc.navigationController?.navigationBar.tintColor = .systemBackground
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        nav.isNavigationBarHidden = false
        
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func setupView(){
        view.backgroundColor = .secondarySystemBackground
        title = "Events"
        let firstButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapNewRemind))
        let secondButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapOpenWeekCalendar))
        navigationItem.rightBarButtonItems = [firstButton, secondButton]
        let vc = EKEventEditViewController()
        vc.editViewDelegate = self
    }
}
//отображение вью с напоминанием в текущий день и закрытие его на кнопку cancel
extension MainViewController: EKEventViewDelegate {
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        controller.dismiss(animated: true)
    }
}
//закрытие вью с отображением и созданием нового напоминания
extension MainViewController:  EKEventEditViewDelegate{
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        dismiss(animated: true)
    }
}
