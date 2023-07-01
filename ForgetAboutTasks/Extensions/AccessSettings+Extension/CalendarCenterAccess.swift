//
//  CalendarCenterAccess.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 01.07.2023.
//

import UIKit
import EventKit

extension UIViewController {
    func request(forAllowing event: EKEventStore,handler: @escaping (Bool)-> ()) {
        switch EKEventStore.authorizationStatus(for: .event){
            
        case .notDetermined:
            event.requestAccess(to: .event) { success, error in
                handler(success)
            }
        case .restricted:
            handler(false)
        case .denied:
            showSettingsForChangingAccess(title: "Switching on Calendar", message: "Do you want to switch on Calendar?") { success in
                handler(success)
            }
        case .authorized:
            handler(true)
        @unknown default:
            break
        }
    }
}
