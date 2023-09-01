//
//  DataProvider.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 06.07.2023.
//

import UIKit

class DataProvider {
    
    /// function for working with url and getting image from it
    /// - Parameters:
    ///   - url: image link for future downloading
    ///   - completion: if success returning downloaded image from url, if not returning system image
    func dataProvider(url: URL, completion: @escaping (UIImage?) -> ()) {
        let request = URLRequest(url: url,cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10)
        let dataTask = URLSession.shared.dataTask(with: request) { data, _, error in
            guard data != nil,
                  error == nil else { return }
            guard let image = UIImage(data: data!) else {
                completion(UIImage(systemName: "person.circle.fill"))
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
        dataTask.resume()
    }
}
