//
//  AlertActionWithURL.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 09.05.2023.
//

import UIKit
import SafariServices

extension UIViewController {
    func futureUserActions(link: String) {
        let alert = UIAlertController(title: nil, message: "What do you want to do with this link", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Open in browser", style: .default,handler: { [weak self] _ in
            if link.contains("http://") || link.contains("https://") {
                guard let link = URL(string:  link) else { return }
                
                let safariVC = SFSafariViewController(url: link)
                self?.present(safariVC, animated: true)
            } else {
                let finalLink = "https://" + link
                guard let link = URL(string: finalLink) else { return }
                let safariVC = SFSafariViewController(url: link)
                self?.present(safariVC, animated: true)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Copy link", style: .default,handler: { [weak self] _ in
            UIPasteboard.general.string = link
            self?.alertDismissed(view: (self?.view)!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
