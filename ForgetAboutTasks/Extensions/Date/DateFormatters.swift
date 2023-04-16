//
//  DateFormatters.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 12.04.2023.
//

import UIKit

extension DateFormatter {
    func dateWithoutTime(date: Date) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .full
        formatter.timeZone = .current
        formatter.string(from: date)
        return formatter
    }
}
