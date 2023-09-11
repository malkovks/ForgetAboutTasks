//
//  UserProfileSetTimerPassword.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 27.08.2023.
//

import UIKit
import SnapKit

class UserProfileSetTimerPassword: UIViewController {
    
    private let timerValue: [String] = ["One hour".localized(),
                                        "Two hours".localized(),
                                        "Three hours".localized(),
                                        "Six hours".localized(),
                                        "Twelve hours".localized(),
                                        "Once a day".localized(),
                                        "Once every two days".localized(),
                                        "Once every three days".localized(),
                                        "Once a week".localized()]
    
    private let timerPasswordPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.tag = 0
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    //MARK: - Target methods
    @objc private func didTapDismiss(){
        self.dismiss(animated: isViewAnimated)
    }
    //MARK: - Setup methods
    private func setupView(){
        setupConstraints()
        setupPickerSetup()
        setupNavigation()
        
    }

    private func setupPickerSetup(){
        timerPasswordPicker.delegate = self
        timerPasswordPicker.dataSource = self
    }
    
    private func setupNavigation(){
        title = "Choose time".localized()
        navigationController?.navigationBar.tintColor = UIColor(named: "calendarHeaderColor")
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(didTapDismiss))
    }
    
    
    /// Function for returning chosen value from timer picker
    /// - Parameter row: input string row from picker view
    /// - Returns: return integer count
    private func returnTimerCount(row : String) -> Int {
        switch row {
        case "One hour" : return 3600
        case "Two hours" : return 3600 * 2
        case "Three hours" : return 3600 * 3
        case "Six hours" : return 3600 * 6
        case "Twelve hours" : return 3600 * 12
        case "Once a day" : return 3600 * 24
        case "Once every two days" : return 3600 * 24 * 2
        case "Once every three days" : return 3600 * 24 * 3
        case "Once a week": return 3600 * 24 * 7
        default:
            return 3600
        }
    }

}

//MARK: - UIPickerView Delegate and DataSource
extension UserProfileSetTimerPassword: UIPickerViewDelegate , UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timerValue.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timerValue[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let timerVariation = timerValue[row]
        let value = returnTimerCount(row: timerVariation)
        UserDefaults.standard.setValue(value, forKey: "timerPassword")   
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = timerValue[row]
        label.font = .setMainLabelFont()
        label.textAlignment = .center
        return label
    }
}
//MARK: - Controller constraints
extension UserProfileSetTimerPassword {
    private func setupConstraints() {
        view.addSubview(timerPasswordPicker)
        timerPasswordPicker.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
    }
}
