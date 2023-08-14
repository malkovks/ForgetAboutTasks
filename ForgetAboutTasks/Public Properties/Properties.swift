//
//  Properties.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 14.08.2023.
//

import UIKit

public let isViewAnimated: Bool = UserDefaults.standard.bool(forKey: "enabledAnimation")
public let fontSizeValue : CGFloat = CGFloat(UserDefaults.standard.float(forKey: "fontSizeChanging"))
