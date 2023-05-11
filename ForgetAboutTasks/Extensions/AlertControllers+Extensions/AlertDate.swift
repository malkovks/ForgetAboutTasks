//
//  AlertDate.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.03.2023.
//

import UIKit
import SnapKit

extension UIViewController {
    func alertDate(table: UITableView,choosenDate: Date?, completiongHandler: @escaping (Int,Date,String) -> Void) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.timeZone = .current
        datePicker.locale = .current
        datePicker.datePickerMode = .date
        datePicker.date = choosenDate ?? Date()
        datePicker.preferredDatePickerStyle = .wheels
        alert.view.addSubview(datePicker)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            let date = datePicker.date
            let dateString = Formatters.instance.stringFromDate(date: date)
            
            let calendar = Calendar.current
            let comp = calendar.dateComponents([.weekday], from: date)
            guard let weekdayComp = comp.weekday else { return }
            let weekday = weekdayComp
            completiongHandler(weekday,date,dateString)
            DispatchQueue.main.async {
                table.reloadData()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        alert.view.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
        datePicker.snp.makeConstraints { make in
            make.width.equalTo(alert.view.snp.width)
            make.height.equalTo(160)
            make.top.equalToSuperview().offset(5)
        }
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalTo: alert.view.widthAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 160).isActive = true
        datePicker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20).isActive = true
        
        present(alert, animated: true)
    }
}
