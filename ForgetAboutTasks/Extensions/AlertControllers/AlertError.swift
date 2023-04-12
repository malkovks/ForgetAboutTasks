//
//  AlertError.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 10.04.2023.
//

import UIKit

extension UIViewController {
    func alertError(text: String = ""){
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
