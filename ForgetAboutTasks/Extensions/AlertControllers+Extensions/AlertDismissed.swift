//
//  AlertDismissed.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.05.2023.
//

import UIKit

extension UIViewController {
    func alertDismissed(view: UIView,title: String = "Text was copied"){
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
    func alertDismissedCustom(onView: UIView,output text: String) {
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        
        let viewBackground = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        view.backgroundColor = UIColor(named: "backgroundColor")
        alert.view.addSubview(viewBackground)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let topVC = UIApplication.shared.keyWindow?.rootViewController {
            alert.popoverPresentationController?.sourceView = onView
            alert.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            topVC.present(alert, animated: true)
        }
    }
}
