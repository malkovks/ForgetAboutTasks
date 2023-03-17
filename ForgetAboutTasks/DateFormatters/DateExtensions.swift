//
//  DateExtensions.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 17.03.2023.
//

import Foundation

extension Date {
    public func setTime(date: Date,hour: Int, min: Int, sec: Int) -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        return date 
    }
    
    
}
