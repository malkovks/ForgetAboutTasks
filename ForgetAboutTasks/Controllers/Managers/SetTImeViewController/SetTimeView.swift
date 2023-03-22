//
//  SetTimeView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 22.03.2023.
//

import UIKit
import SnapKit

class SetTimeView: UIView {

    let timePicker: UIDatePicker = {
        let picker = UIDatePicker(frame: .zero)
        picker.locale = NSLocale(localeIdentifier: "Ru_ru") as Locale
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.timeZone = .current
        picker.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        picker.backgroundColor = .secondarySystemBackground
        return picker
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .systemBlue
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SetTimeView {
    private func setupConstraints(){
        addSubview(timePicker)
        timePicker.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview().inset(0)
        }
    }
}
