//
//  AlertContacts.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 07.04.2023.
//

import UIKit

extension UIViewController {
    
    func alertFriends(completion: @escaping (String) -> Void) {
        setupHapticMotion(style: .soft)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Friend".localized(), style: .default,handler: { _ in
            completion("Friend")
        }))
        alert.addAction(UIAlertAction(title: "Colleague".localized(), style: .default,handler: { _ in
            completion("Colleague")
        }))
        alert.addAction(UIAlertAction(title: "Family".localized(), style: .default,handler: { _ in
            completion("Family")
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: isViewAnimated)
    }
}
