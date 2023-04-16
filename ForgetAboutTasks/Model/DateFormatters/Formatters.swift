//
//  Formatters.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 11.03.2023.
//

import UIKit

class Formatters {
    
    static let instance = Formatters()
    
    lazy var dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
//        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    public func stringFromDate(date: Date) -> String{
        let string = self.dateFormatter.string(from: date)
        return string
    }
    
    public func dateString(date: Date) -> String {
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    public func standartedDate(date: Date) -> Date {
        let comp = Calendar.current.dateComponents([.day,.month,.year], from: date)
        
        let returnDate = Calendar.current.date(from: comp)
        return returnDate ?? Date()
    }
    public func dateStringFromDate(_ inputDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let dateString = formatter.string(from: inputDate)
        return dateString
    }
    
    public func timeStringFromDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = .current
        let time = formatter.string(from: date)
        return time
    }
}

extension Formatter {
    static let weekDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter
    }()
}
