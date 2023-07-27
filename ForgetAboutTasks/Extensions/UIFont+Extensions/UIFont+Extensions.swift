//
//  UIFont+Extensions.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 20.07.2023.
//

import UIKit

extension UIFont {
    func setupFont(size: CGFloat = 16,name: String = "Times New Roman", weight: UIFont.Weight = .medium) -> UIFont{
        let font = UIFont(name: name, size: size)!
        return font
    }
}
