//
//  AlertSpinner.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 02.04.2023.
//

import UIKit

extension UIViewController {
    
    /// Function for displaying custom alert with timer 2
    func setupLoadingSpinner(){
        let alert = UIAlertController(title: "", message: "Please wait...".localized(), preferredStyle: .alert)
        let loadingAlert = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingAlert.hidesWhenStopped = true
        loadingAlert.style = .medium
        loadingAlert.startAnimating()
        alert.view.addSubview(loadingAlert)
        view.alpha = 0.8
        present(alert, animated: isViewAnimated)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.navigationController?.popToRootViewController(animated: isViewAnimated)
            self.view.alpha = 1.0
            alert.dismiss(animated: isViewAnimated)
        }
    }
}
