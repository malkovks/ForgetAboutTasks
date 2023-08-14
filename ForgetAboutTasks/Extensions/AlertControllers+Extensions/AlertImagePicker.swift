//
//  AlertImagePicker.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 07.04.2023.
//

import UIKit

extension UIViewController {
    
    func alertImagePicker(completion: @escaping (UIImagePickerController.SourceType) -> Void) {
        setupHapticMotion(style: .soft)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default,handler: { _ in
            completion(.camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default,handler: { _ in
            completion(.photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Saved Photo Album", style: .default,handler: { _ in
            completion(.savedPhotosAlbum)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: isViewAnimated)
    }
}
