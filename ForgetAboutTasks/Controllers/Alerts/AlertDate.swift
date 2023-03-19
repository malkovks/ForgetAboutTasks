//
//  AlertDate.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.03.2023.
//

import UIKit
import SnapKit

extension UIViewController {
    func alertDate(label: UILabel, completiongHandler: @escaping (Int,NSDate) -> Void) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        alert.view.addSubview(datePicker)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            let date = datePicker.date as NSDate
            let dateString = Formatters.instance.stringFromDate(date: date as Date)
            
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.weekday], from: date as Date)
            guard let weekdayComp = comp.weekday else { return }
            let weekday = weekdayComp
            completiongHandler(weekday,date)
            
            label.text = dateString
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        alert.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalTo: alert.view.widthAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 160).isActive = true
        datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20).isActive = true
        present(alert, animated: true)
    }
}
