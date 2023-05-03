//
//  AlertTime.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.03.2023.
//

import UIKit
import SnapKit

extension UIViewController {
    func alertTime(table: UITableView,choosenDate: Date, completiongHandler: @escaping (Date,String) -> Void) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.locale = .current
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = NSLocale(localeIdentifier: "Ru_ru") as Locale
        alert.view.addSubview(datePicker)
        
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .current
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            let timeString = dateFormatter.string(from: datePicker.date)
            let date = datePicker.date
            completiongHandler(date,timeString)
            
            DispatchQueue.main.async {
                table.reloadData()
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
