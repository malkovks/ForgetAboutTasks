//
//  AlertSpinner.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 02.04.2023.
//

import UIKit

extension UIViewController {
    func setupLoadingSpinner(){
        let alert = UIAlertController(title: "", message: "Please wait...", preferredStyle: .alert)
        let loadingAlert = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingAlert.hidesWhenStopped = true
        loadingAlert.startAnimating()
        alert.view.addSubview(loadingAlert)
        view.alpha = 0.8
        present(alert, animated: true)
    }
}
