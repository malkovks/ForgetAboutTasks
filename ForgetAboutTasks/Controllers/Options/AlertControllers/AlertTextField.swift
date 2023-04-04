//
//  AlertTextField.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//

import UIKit

extension UIViewController {
    func alertTextField(cell title: String,placeholder: String,table: UITableView, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "", message: title, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { text in
            text.placeholder = placeholder
        })
        alert.addAction(UIAlertAction(title: "Save", style: .default,handler: { _ in
            DispatchQueue.main.async {
                completion(alert.textFields?.first?.text ?? "")
                table.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
