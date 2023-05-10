//
//  AlertDismissed.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.05.2023.
//

import UIKit

extension UIViewController {
    func alertDismissed(view: UIView){
        let alert = UIAlertController(title: "Text was copied", message: nil, preferredStyle: .actionSheet)
        present(alert, animated: true)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: 0, width: 0, height: 0)
        alert.popoverPresentationController?.permittedArrowDirections = [.up]
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            alert.dismiss(animated: true)
        }
    }
}
