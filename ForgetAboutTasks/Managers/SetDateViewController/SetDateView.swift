//
//  SetDateView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 22.03.2023.
//

import UIKit
import SnapKit

class SetDateView: UIView {

    let calendarPicker: UIDatePicker = {
        let picker = UIDatePicker(frame: .zero)
        picker.locale = .current
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.tintColor = #colorLiteral(red: 0.3555810452, green: 0.3831118643, blue: 0.5100654364, alpha: 1)
        picker.backgroundColor = .secondarySystemBackground
//        picker.preferredDatePickerStyle = .compact
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

extension SetDateView {
    private func setupConstraints(){
        addSubview(calendarPicker)
        calendarPicker.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview().inset(0)
        }
    }
}
