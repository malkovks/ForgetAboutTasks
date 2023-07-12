//
//  UserProfileAppIconViewVC.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 03.07.2023.
//

import UIKit
import SnapKit

class UserProfileAppIconViewController: UIViewController {
    
    private let images = ["AppIcon", "AppIcon2","AppIcon3","AppIcon4"]
    
    private let firstIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.tag = 0
        button.setImage(UIImage(named: "AppIcon"), for: .normal)
        
        return button
    }()

    private let secondIconButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.tag = 1
        button.setImage(UIImage(named: "AppIcon2"), for: .normal)
        return button
    }()
    
    private let thirdIconButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.tag = 2
        button.setImage(UIImage(named: "AppIcon3"), for: .normal)
        return button
    }()
    
    private let forthIconButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.tag = 3
        button.setImage(UIImage(named: "AppIcon4"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewAndNavigation()
        
    }
    //MARK: - Target methods
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    @objc private func didTapChangeImage(sender: UIButton){
        switch sender.tag {
        case 0: setupAppIcon(named: images[sender.tag])
        case 1: setupAppIcon(named: images[sender.tag])
        case 2: setupAppIcon(named: images[sender.tag])
        case 3: setupAppIcon(named: images[sender.tag])
        default:
            break
        }
    }
    
    
    //MARK: - Setup Method
    private func setupViewAndNavigation(){
        setConstraints()
        view.backgroundColor = UIColor(named: "backgroundColor")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapDismiss))
        title = "Choose App Icon".localized()
        firstIconButton.addTarget(self, action: #selector(didTapChangeImage(sender: )), for: .touchUpInside)
        secondIconButton.addTarget(self, action: #selector(didTapChangeImage(sender: )), for: .touchUpInside)
        thirdIconButton.addTarget(self, action: #selector(didTapChangeImage(sender: )), for: .touchUpInside)
        forthIconButton.addTarget(self, action: #selector(didTapChangeImage(sender: )), for: .touchUpInside)
    }
    
    private func setupAppIcon(named iconName: String?) {
        
        guard UIApplication.shared.supportsAlternateIcons else { alertError(text: "Cant get access to change Image".localized()); return }
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                self.alertError(text: error.localizedDescription)
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5){
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
}

extension UserProfileAppIconViewController {
    private func setConstraints(){

        let stackView = UIStackView(arrangedSubviews: [firstIconButton,secondIconButton,thirdIconButton,forthIconButton])
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.contentMode = .scaleAspectFit
        stackView.axis = .horizontal
        stackView.spacing = 10
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(80)
        }
        
//        view.addSubview(firstIconButton)
//        firstIconButton.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(60)
//            make.leading.equalToSuperview().offset(15)
//            make.height.width.equalTo(80)
//        }
//        view.addSubview(secondIconButton)
//        secondIconButton.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(60)
//            make.leading.equalTo(firstIconButton.snp.trailing).offset(15)
//            make.height.width.equalTo(80)
//        }
//        view.addSubview(thirdIconButton)
//        thirdIconButton.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(60)
//            make.leading.equalTo(secondIconButton.snp.trailing).offset(15)
//            make.height.width.equalTo(80)
//        }
//        view.addSubview(forthIconButton)
//        forthIconButton.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(60)
//            make.leading.equalTo(thirdIconButton.snp.trailing).offset(15)
//            make.trailing.equalToSuperview().inset(15)
//            make.height.width.equalTo(80)
//        }
    }
}
