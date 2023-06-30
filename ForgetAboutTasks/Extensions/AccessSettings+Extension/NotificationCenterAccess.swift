//
//  NotificationCenterAccess.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 30.06.2023.
//

import UIKit

extension UIViewController {
    func showNotificationCenterSetting(){
        let alert = UIAlertController(title: "Access to Notifications was denied", message: "You need to go to settings to switch on notifications", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
