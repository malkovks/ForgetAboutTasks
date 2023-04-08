//
//  ColorExtensions.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 08.04.2023.
//

import UIKit

extension UIColor {
    func colorFromHex(_ hex: String) -> UIColor {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        if hex.count != 6 {
            return #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        return UIColor(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgb & 0xFF0000) >> 8) / 255.0,
                       blue: CGFloat(rgb & 0xFF0000) / 255.0,
                       alpha: 1.0)
    }
}
