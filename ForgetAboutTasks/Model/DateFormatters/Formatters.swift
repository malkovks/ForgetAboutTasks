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
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    public func stringFromDate(date: Date) -> String{
        let string = self.dateFormatter.string(from: date)
        return string + " г."
    }
    
    public func dateStringFromDate(_ inputDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let dateString = formatter.string(from: inputDate)
        return dateString
    }
    
    public func timeStringFromDate(date: Date) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return "\(hour) : \(minute)"
        
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
