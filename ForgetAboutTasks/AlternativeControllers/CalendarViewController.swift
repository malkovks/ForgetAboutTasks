//
//  ViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 06.03.2023.
//

import UIKit
import CalendarKit
import EventKit
import EventKitUI

class CalendarViewController: DayViewController {
    
    private let eventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc private func didTapNotification(_ notification: Notification){
        reloadData()
    }
    
    @objc private func didTapNextView(){
        let vc = SecondViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.sheetPresentationController?.detents = [.large()]
        nav.sheetPresentationController?.prefersGrabberVisible = true
        nav.isNavigationBarHidden = false
        present(nav, animated: true)
    }
    
    @objc private func didTapReturn(){
        self.dismiss(animated: true)
    }
    
    private func setupView(){
        title = "Calendar"
        view.backgroundColor = .systemBackground
        requestAccessToCalendar()
        setupNotification()
        setupNavigationController()
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapNextView))
    }
    
    private func setupNavigationController(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(didTapReturn))
    }
    
    private func requestAccessToCalendar(){
        eventStore.requestAccess(to: .event) { success, error in
        }
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didTapNotification(_ :)),
                                               name: .EKEventStoreChanged,
                                               object: nil)
    }
    

    
    private func openDetailVC(event: EKEvent){
        let eventViewController = EKEventViewController()
        eventViewController.event = event
        eventViewController.allowsCalendarPreview = true
        eventViewController.allowsEditing = true
        navigationController?.pushViewController(eventViewController, animated: true)
    }
    
    private func openEditingVC(event: EKEvent){
        let vc = EKEventEditViewController()
        vc.editViewDelegate = self
        vc.event = event
        vc.eventStore = eventStore
        present(vc, animated: true, completion: nil)
    }
    
    
    //наследование задач из главного EKEvent в наше приложение
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let startDate = date
        var dayComponents = DateComponents()
        dayComponents.day = 1
        let endDate = calendar.date(byAdding: dayComponents, to: startDate)!
        let predicate = eventStore.predicateForEvents(withStart: startDate,
                                                      end: endDate,
                                                      calendars: nil)
        let eventKitEvents = eventStore.events(matching: predicate)
        let calendarKit = eventKitEvents.map(EKWrapper.init)
        //метод, который мы использовали уже в EKWrapper
//        let calendarKit = eventKitEvents.map { ekEvent -> EKWrapper in
//            let ckEvent = EKWrapper()
//            ckEvent.startDate = ekEvent.startDate
//            ckEvent.endDate = ekEvent.endDate
//            ckEvent.isAllDay = ekEvent.isAllDay
//            ckEvent.text = ekEvent.title
//            if let eventColor = ekEvent.calendar.cgColor {
//                ckEvent.color = UIColor(cgColor: eventColor)
//            }
//            return ckEvent
//        }
        return calendarKit
    }
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else { return }
        let ekEvent = ckEvent.ekEvent
        openDetailVC(event: ekEvent)
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        endEventEditing()
        guard let ckEvent = eventView.descriptor as? EKWrapper else { return }
        beginEditing(event: ckEvent, animated: true)
    }
    
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        var hour = DateComponents()
        hour.hour = 1
        let endDate = calendar.date(byAdding: hour, to: date)
        
        newEKEvent.startDate = date
        newEKEvent.endDate = endDate
        newEKEvent.title = "New event"
        
        let newEKWrapper = EKWrapper(eventKitEvent: newEKEvent)
        newEKWrapper.editedEvent = newEKWrapper
        
        create(event: newEKWrapper,animated: true)
    }
    
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        guard let editingEvent = event as? EKWrapper else { return print("error") }
        if let originalEvent = event.editedEvent {
            originalEvent.commitEditing()
            
            if originalEvent === editingEvent {
                print("equal")
                openEditingVC(event: editingEvent.ekEvent)
            } else {
                try! eventStore.save(editingEvent.ekEvent, span: .thisEvent)
            }
            
        }
    }
    
    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
    }
    
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
    }
    

}

extension CalendarViewController: EKEventEditViewDelegate{
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        endEventEditing()
        reloadData()
        controller.dismiss(animated: true)
    }
}

