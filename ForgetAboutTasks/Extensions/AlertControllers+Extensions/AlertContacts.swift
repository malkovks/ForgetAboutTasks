//
//  AlertContacts.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 07.04.2023.
//

import UIKit

extension UIViewController {
    
    func alertFriends(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Friend", style: .default,handler: { _ in
            completion("Friend")
        }))
        alert.addAction(UIAlertAction(title: "Colleague", style: .default,handler: { _ in
            completion("Colleague")
        }))
        alert.addAction(UIAlertAction(title: "Family", style: .default,handler: { _ in
            completion("Family")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
