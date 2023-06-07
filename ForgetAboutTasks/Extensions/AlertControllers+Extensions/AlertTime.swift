//
//  AlertTime.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.03.2023.
//

import UIKit
import SnapKit

extension UIViewController {
    func alertTime(choosenDate: Date, completiongHandler: @escaping (Date,String) -> Void) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.locale = .current
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.calendar.firstWeekday = 2
        alert.view.addSubview(datePicker)
        
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .current
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from: datePicker.date)
            
            let date = datePicker.date

            completiongHandler(date,timeString)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        alert.view.snp.makeConstraints { make in
            make.height.equalTo(400)
        }
        
        datePicker.snp.makeConstraints { make in
            make.width.equalTo(alert.view.snp.width)
            make.height.equalTo(260)
            make.top.equalTo(alert.view.snp.top).offset(20)
        }
        present(alert, animated: true)
    }
    
    
    func alertTimeInline(table: UITableView, choosenDate: Date, completionHandler: @escaping (Date,String,Int) -> Void) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.locale = .current
        datePicker.datePickerMode = .dateAndTime
        datePicker.date = choosenDate
        datePicker.preferredDatePickerStyle = .inline
        alert.view.addSubview(datePicker)
        
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            
            let date = datePicker.date
            
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.weekday], from: date)
            guard let weekdayComp = comp.weekday else { return }
            let weekday = weekdayComp
            let timeString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
            completionHandler(date,timeString,weekday)
            
            DispatchQueue.main.async {
//                table.reloadData()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        alert.view.snp.makeConstraints { make in
            make.height.equalTo(540)
        }
        
        datePicker.snp.makeConstraints { make in
            make.width.equalTo(alert.view.snp.width)
            make.height.equalTo(400)
            make.top.equalTo(alert.view.snp.top).offset(20)
        }
        present(alert, animated: true)
    }
}
