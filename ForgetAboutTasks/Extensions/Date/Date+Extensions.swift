//
//  Date+Extensions.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 02.08.2023.
//

import Foundation

extension Date {
    func getDateWithoutYear(date: Date?, currentYearDate : Date = Date()) -> Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentYearDate )
        let customMonth = calendar.component(.month, from: date ?? self)
        let customDay = calendar.component(.day, from: date ?? self)
        
        var components = DateComponents()
        components.year = currentYear
        components.month = customMonth
        components.day = customDay
        
        let valueDate = calendar.date(from: components) ?? Date()
        
        return valueDate
        
    }
}
