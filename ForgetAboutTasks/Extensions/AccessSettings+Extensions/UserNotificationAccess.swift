//
//  NotificationCenterAccess.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 30.06.2023.
//

import UIKit
import UserNotifications

extension UIViewController {
    
    /// Request for access to UserNotifications
    /// - Parameters:
    ///   - notification: current UNUserNotificationCenter
    ///   - handler: return boolean value of accessing to notification
    func request(forUser notification: UNUserNotificationCenter,handler: @escaping (Bool) -> Void){
        notification.requestAuthorization(options: [.alert,.badge,.sound]) { success, error in
            switch success {
            case true:
                handler(true)
            case false:
                handler(false)
                DispatchQueue.main.async {
                    self.showSettingsForChangingAccess(title: "Switching on Notifications".localized(), message: "Do you want to switch on Notifications?".localized()) { _ in
                    }
                }
            }
        }
    }
    
    /// Check for access to UserNotifications
    /// - Parameter handler: return boolean value of access to UserNotifications
    func showNotificationAccessStatus(handler: @escaping (Bool)-> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
                
            case .notDetermined, .denied:
                handler(false)
            case .authorized:
                handler(true)
            case .provisional:
                handler(false)
            case .ephemeral:
                handler(false)
            @unknown default:
                break
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    /// Function usually used for restarting app for updating all layouts and subviews after some external changes in settings
    func restartApp(){
        guard let window = UIApplication.shared.keyWindow else { return }
        setupHapticMotion(style: .soft)
        let vc = TabBarViewController()
        window.rootViewController = vc
        UIView.transition(with: window, duration: 1,options: .transitionCrossDissolve, animations: nil)
    }
    
    /// Function for set up chosen language by user
    /// - Parameter languageCode: language code
    func setupAppLanguage(languageCode: String) {
        setupHapticMotion(style: .soft)
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    /// Function with custom UIAlertController with choosing localization of application
    /// - Parameters:
    ///   - title: custom title string if it necesary
    ///   - message: custom message(subtitle)
    ///   - handler: return language code
    func showVariationsWithLanguage(title: String, message: String, handler: @escaping (String) -> ()){
        setupHapticMotion(style: .soft)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Russia", style: .default,handler: { _ in
            self.setupAppLanguage(languageCode: "ru")
            self.restartApp()
        }))
        alert.addAction(UIAlertAction(title: "English", style: .default,handler: { _ in
            self.setupAppLanguage(languageCode: "en")
            self.restartApp()
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: isViewAnimated)
    }
    
    /// Function necessary for segue to System settings after user changing some access to applications settings
    /// - Parameters:
    ///   - title: title of alert
    ///   - message: subtitle of alert
    ///   - handler: return status dependency on users access
    func showSettingsForChangingAccess(title: String, message: String,handler: @escaping (Bool)-> ()){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Settings".localized(), style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                handler(true)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel,handler: { _ in
            handler(false)
        }))
        present(alert, animated: isViewAnimated)
    }
}
