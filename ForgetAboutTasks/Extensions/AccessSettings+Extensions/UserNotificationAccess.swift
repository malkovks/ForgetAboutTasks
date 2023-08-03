//
//  NotificationCenterAccess.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 30.06.2023.
//

import UIKit
import UserNotifications

extension UIViewController {
    
    func request(forUser notification: UNUserNotificationCenter,handler: @escaping (Bool) -> Void){
        notification.requestAuthorization(options: [.alert,.badge,.sound]) { success, error in
            switch success {
            case true:
                handler(true)
            case false:
                handler(false)
                DispatchQueue.main.async {
                    self.showSettingsForChangingAccess(title: "Switching on Notifications", message: "Do you want to switch on Notifications?") { _ in
                    }
                }
            }
        }
    }
    
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
    
    func restartApp(){
        guard let window = UIApplication.shared.keyWindow else { return }
        let vc = TabBarViewController()
        window.rootViewController = vc
        UIView.transition(with: window, duration: 1,options: .transitionCrossDissolve, animations: nil)
    }
    
    func setupAppLanguage(languageCode: String) {
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    
    func showVariationsWithLanguage(title: String, message: String, handler: @escaping (Bool) -> ()){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Russia", style: .default,handler: { _ in
            self.setupAppLanguage(languageCode: "ru")
            self.restartApp()
        }))
        alert.addAction(UIAlertAction(title: "English", style: .default,handler: { _ in
            self.setupAppLanguage(languageCode: "en")
            self.restartApp()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func showSettingsForChangingAccess(title: String, message: String,handler: @escaping (Bool)-> ()){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                handler(true)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: { _ in
            handler(false)
        }))
        present(alert, animated: true)
    }
}
