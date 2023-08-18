//
//  UserProfileNapticView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 08.08.2023.
//

import UIKit
import SnapKit


//class UserProfileNapticViewController: UIViewController {
//
//    let customView = UserProfileNapticView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.addSubview(customView)
//    }
//}
//
//class CustomPickerView: UIPickerView {
//    let pickerView = UIPickerView()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        pickerView.backgroundColor = .systemRed
//        pickerView.tintColor = .systemBlue
//        addSubview(pickerView)
//        pickerView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

class UserProfileNapticView: UIView {
    
    let napticValue = ["Light","Medium","Hard"]
    
    let popupView: UIView = {
       let view  = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    let napticPicker: UIPickerView = {
       let picker = UIPickerView()
        picker.tag = 0
        return picker
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCustomView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCustomView(){
        setupViewConstraints()
        napticPicker.delegate = self
        napticPicker.dataSource = self
    }
    
}

extension UserProfileNapticView: UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        napticValue.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = napticValue[row]
        label.font = UIFont.setMainLabelFont()
        label.textAlignment = .center
        return label
    }
}

extension UserProfileNapticView {
    private func setupViewConstraints(){
        addSubview(popupView)
        popupView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        popupView.addSubview(napticPicker)
        napticPicker.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
    }
}
