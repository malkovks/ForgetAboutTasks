//
//  DownloadImage.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 20.04.2023.
//

import UIKit

extension UIViewController {
    func downloadImage(url: URL,handler: @escaping (Data) -> Void) {
        URLSession.shared.dataTask(with: url) { data, request, error in
            guard let data = data,
                  error == nil else {
                print("Error downloading data")
                return
            }
            DispatchQueue.main.async {
                handler(data)
            }
        }
    }
}
