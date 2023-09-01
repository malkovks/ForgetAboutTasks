//
//  CalendarCenterAccess.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 01.07.2023.
//

import UIKit
import EventKit

extension UIViewController {
    
    /// function for asking access to EKEventStore
    /// - Parameters:
    ///   - event: input event store
    ///   - handler: returning boolean status of access to Event
    func request(forAllowing event: EKEventStore,handler: @escaping (Bool)-> ()) {
        DispatchQueue.main.async {
            switch EKEventStore.authorizationStatus(for: .event){

            case .notDetermined:
                event.requestAccess(to: .event) { success, error in
                    handler(success)
                }
            case .restricted:
                handler(false)
            case .denied:
                event.requestAccess(to: .event) { success, error in
                    handler(success)
                }
            case .authorized:
                handler(true)
            @unknown default:
                break
            }
        }
        
    }
}
