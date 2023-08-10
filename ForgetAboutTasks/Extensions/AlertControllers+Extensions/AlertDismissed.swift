//
//  AlertDismissed.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.05.2023.
//

import UIKit

extension UIViewController {
    func alertDismissed(view: UIView,title: String = "Text was copied"){
        setupHapticMotion(style: .light)
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.preferredContentSize = CGSize(width: 400, height: 200)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: 0, width: 0, height: 0)
        alert.popoverPresentationController?.permittedArrowDirections = [.up]
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            alert.dismiss(animated: true)
        }
    }
}
