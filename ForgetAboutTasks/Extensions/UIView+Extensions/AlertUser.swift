//
//  AlertUser.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 16.05.2023.
//

import UIKit

extension UIViewController {
    func showAlertForUser(text: String,duration: DispatchTime,controllerView: UIView){
        let customView = UIView()
        customView.backgroundColor = UIColor(named: "cellColor")
        customView.layer.cornerRadius = 12
        self.view.addSubview(customView)
        customView.snp.makeConstraints { make in
            make.top.equalTo(controllerView.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(view.frame.size.width/3)
            make.height.equalTo(view.frame.size.height/20)
            
        }
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium, width: .standard)
        label.text = text
        label.numberOfLines = 0
        label.textColor = UIColor(named: "textColor")
        label.textAlignment = .center
        customView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(customView.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(5)
            make.bottom.equalTo(customView.safeAreaLayoutGuide.snp.bottom)
        }
        
        UIView.animate(withDuration: 0.5) {
            label.alpha = 1.0
            customView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        
        DispatchQueue.main.asyncAfter(deadline: duration) {
            UIView.animate(withDuration: 0.5,delay: 0) {
                customView.alpha = 0.0
                customView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            } completion: { success in
                customView.removeFromSuperview()
            }
        }
    }
}
