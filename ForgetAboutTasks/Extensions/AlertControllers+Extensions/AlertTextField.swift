//
//  AlertTextField.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//

import UIKit

extension UIViewController: UITextFieldDelegate {
    
    
    func alertTextField(cell title: String,placeholder: String,keyboard type: UIKeyboardType,table: UITableView, completion: @escaping (String) -> Void) {
        
        let alert = UIAlertController(title: "", message: title, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { [self] textField in
            textField.placeholder = placeholder
            textField.clearButtonMode = .whileEditing
            textField.keyboardType = type
            textField.resignFirstResponder()
            textField.delegate = self
            textField.returnKeyType = .continue
            
            if type == .default {
                textField.autocapitalizationType = .sentences
                textField.autocorrectionType = .yes
            } else {
                textField.autocapitalizationType = .none
                textField.autocorrectionType = .no
            }
            textField.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(64)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.greaterThanOrEqualTo(30)
            }
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        })
        let saveAction = UIAlertAction(title: "Save", style: .default,handler: { _ in
            DispatchQueue.main.async {
                guard let text = alert.textFields?.first?.text else {
                    self.alertError(text: "Error value!")
                    return
                }
                if !text.isEmpty {
                    completion(text)
                    table.reloadData()
                } else {
                    self.alertError(text: "Enter some value!")
                }
            }
        })
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.editButtonItem.tintColor = UIColor(named: "navigationControllerColor")
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        //НЕ РАБОТАЕТ кнопка скрытия клавиатуры
        let doneB = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.toolBarDoneButtonTapped))
        doneB.tintColor = UIColor(named: "navigationControllerColor")
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace,doneB], animated: true)
        
        alert.textFields?.first?.inputAccessoryView = toolbar

        
        present(alert, animated: true)
    }
    
    @objc func toolBarDoneButtonTapped(_ textField: UITextField){
        
        print("work")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        let minHeight:CGFloat = 40
        let contentHeight = textField.sizeThatFits(CGSize(width: textField.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        textField.snp.updateConstraints { make in
            make.height.greaterThanOrEqualTo(max(minHeight, contentHeight))
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
