//
//  Date+Extensions.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 02.08.2023.
//

import Foundation

extension Date {
    
    /// function for converting random date on date with custom year
    /// - Parameters:
    ///   - date: current date
    ///   - currentYearDate: chosen date
    /// - Returns: converted date with year from chosen date
    func getDateWithoutYear(currentYearDate : Date = Date()) -> Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentYearDate )
        let customMonth = calendar.component(.month, from: self)
        let customDay = calendar.component(.day, from: self)
        
        var components = DateComponents()
        components.year = currentYear
        components.month = customMonth
        components.day = customDay
        
        let valueDate = calendar.date(from: components) ?? Date()
        
        return valueDate
    }
    
    /// Func for converting data from user birthday date to persons year
    /// - Parameters:
    ///   - birthday date
    ///   - specifiedDate: chosen date
    /// - Returns: age of user at chosen date(year)
    func getContactUserAge(specifiedDate: Date) -> Int {
        let calendar = Calendar.current
        let ageComp = calendar.dateComponents([.year], from: self,to: specifiedDate)
        let age = ageComp.year ?? 0
        return age
        
    }
}
