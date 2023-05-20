//
//  AlertTextField.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//

import UIKit

extension UIViewController {
    func alertTextField(cell title: String,placeholder: String,keyboard type: UIKeyboardType,table: UITableView, completion: @escaping (String) -> Void) {
        
        let alert = UIAlertController(title: "", message: title, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { [self] text in
            text.placeholder = placeholder
            text.clearButtonMode = .whileEditing
            text.autocapitalizationType = .sentences
            text.keyboardType = type
            text.resignFirstResponder()
            if text.keyboardType == .emailAddress && text.keyboardType == .URL {
                text.autocapitalizationType = .none
            }
            text.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(64)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.greaterThanOrEqualTo(30)
            }
            text.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            
            let doneB = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
            doneB.tintColor = UIColor(named: "navigationControllerColor")
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbar.setItems([flexibleSpace,doneB], animated: true)
            
            text.inputAccessoryView = toolbar
            
            
        })
        alert.addAction(UIAlertAction(title: "Save", style: .default,handler: { _ in
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
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.editButtonItem.tintColor = UIColor(named: "navigationControllerColor")
        
        present(alert, animated: true)
    }
    
    @objc private func doneButtonTapped(){
        print("done button is work correctly")
        view.endEditing(true)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField){
        let minHeight:CGFloat = 40
        let contentHeight = textField.sizeThatFits(CGSize(width: textField.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height
        textField.snp.updateConstraints { make in
            make.height.greaterThanOrEqualTo(max(minHeight, contentHeight))
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
