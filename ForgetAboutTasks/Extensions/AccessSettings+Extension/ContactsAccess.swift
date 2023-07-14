//
//  ContactsAccess.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 14.07.2023.
//

import UIKit
import Contacts
import ContactsUI

extension UIViewController {
    
    func requestAccessForInheritContacts(handler: @escaping (Bool?)->()){
        let contactStore = CNContactStore()
        DispatchQueue.main.async { [weak self] in
            contactStore.requestAccess(for: .contacts) { success, error in
                switch success {
                case true:
                    handler(success)
                case false:
                    self?.alertError(text: "Give access to app in Settings if it will be neccessary".localized(), mainTitle: "Error!".localized())
                    handler(success)
                }
            }
        }
        
    }
    
    func checkAuthForContacts(handler: @escaping (Bool) -> Void) {
        DispatchQueue.main.async { [weak self] in
            switch CNContactStore.authorizationStatus(for: .contacts){
                
            case .notDetermined:
                self?.requestAccessForInheritContacts { success in
                    handler(success ?? false)
                }
            case .restricted:
                self?.requestAccessForInheritContacts { success in
                    handler(success ?? false)
                }
            case .denied:
                self?.requestAccessForInheritContacts { success in
                    handler(success ?? false)
                }
            case .authorized:
                self?.requestAccessForInheritContacts { success in
                    handler(success ?? true)
                }
            @unknown default:
                handler(false)
            }
        }
    }
}
