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
            text.keyboardType = type
//            if type == .phonePad {
//                text.
//            }
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
}
