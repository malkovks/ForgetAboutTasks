//
//  PressButtonProtocols.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 08.04.2023.
//

import Foundation

protocol PressReadyTaskButtonProtocol: AnyObject{
    func readyButtonTapped(index: IndexPath)
}

protocol SwitchRepeatProtocol: AnyObject {
    func switchRepeat(value: Bool)
}
