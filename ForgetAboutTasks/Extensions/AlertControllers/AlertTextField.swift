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
        alert.addTextField(configurationHandler: { text in
            text.placeholder = placeholder
            text.autocapitalizationType = .sentences
            text.keyboardType = type
            if text.keyboardType == .emailAddress && text.keyboardType == .URL {
                text.autocapitalizationType = .none
            }
            text.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(64)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.greaterThanOrEqualTo(30)
            }
            text.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
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
        
        
        present(alert, animated: true)
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
