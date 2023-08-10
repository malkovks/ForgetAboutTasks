//
//  HapticManager.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 10.08.2023.
//

import UIKit

extension UIViewController {
    func setupHapticMotion(style: UIImpactFeedbackGenerator.FeedbackStyle){
        let enableHaptic = UserDefaults.standard.bool(forKey: "enableVibration")
        if enableHaptic {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}
