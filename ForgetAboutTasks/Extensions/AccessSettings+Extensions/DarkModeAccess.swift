//
//  DarkModeAccess.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 29.07.2023.
//

import UIKit

extension UIViewController {
    func setupSwitchDarkMode() -> Bool {
        let windows = UIApplication.shared.windows
        if windows.first?.overrideUserInterfaceStyle == .dark {
            UserDefaults.standard.setValue(true, forKey: "setUserInterfaceStyle")
            return true
        } else {
            UserDefaults.standard.setValue(false, forKey: "setUserInterfaceStyle")
            return false
        }
    }
}
