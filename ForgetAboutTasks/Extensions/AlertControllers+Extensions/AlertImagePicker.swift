//
//  AlertImagePicker.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 07.04.2023.
//

import UIKit

extension UIViewController {
    
    
    /// Function for presenting alert controller with choosing type of work with user's media
    /// - Parameter completion: return source type 
    func alertImagePicker(completion: @escaping (UIImagePickerController.SourceType) -> Void) {
        setupHapticMotion(style: .soft)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera".localized(), style: .default,handler: { _ in
            completion(.camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library".localized(), style: .default,handler: { _ in
            completion(.photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Saved Photo Album".localized(), style: .default,handler: { _ in
            completion(.savedPhotosAlbum)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        present(alert, animated: isViewAnimated)
    }
}
