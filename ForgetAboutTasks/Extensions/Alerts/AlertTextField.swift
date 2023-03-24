//
//  AlertTextField.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//

import UIKit

extension UIViewController {
    func alertTextField(subtitle: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "", message: "Enter text to \(subtitle) cell", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { text in
            text.placeholder = "Enter text"
        })
        alert.addAction(UIAlertAction(title: "Save", style: .default,handler: { _ in
            DispatchQueue.main.async {
                completion(alert.textFields![0].text!)
                print(alert.textFields![0].text ?? "")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cance;", style: .cancel))
        present(alert, animated: true)
    }
}
