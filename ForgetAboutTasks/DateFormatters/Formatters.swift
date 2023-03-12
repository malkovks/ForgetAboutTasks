//
//  Formatters.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 11.03.2023.
//

import UIKit

class Formatters {
    
    static let instance = Formatters()
    
    public func dateStringFromDate(_ inputDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let dateString = formatter.string(from: inputDate)
        return dateString
    }
}
