//
//  UserProfileFooterView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 29.07.2023.
//

import UIKit

///Custom UIView for displaying footer of UserProfile UITableView
class UserProfileFooterView: UIView {

    let footerView: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let footerLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .justified
        label.contentMode = .scaleAspectFit
        label.sizeToFit()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .thin)
        if UIApplication.shared.connectedScenes.first?.inputView?.overrideUserInterfaceStyle == .light {
            label.textColor = .darkGray
        } else {
            label.textColor = .lightText
        }
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Setup function for returning text to label
    /// - Parameter section: input indexPath.section
    func setupTextLabel(section: Int){
        switch section {
        case 0: footerLabel.text = "This settings need for switching on/off access to some services. It will segue to Main Settings for changing value.".localized()
        case 1: footerLabel.text = "This settings allow you to switch on/off password, set timer how offen application will request you password and set allowing to Face ID".localized()
        case 2: footerLabel.text = "You can change app icon, font of application, enable animation and vibration".localized()
        case 3: footerLabel.text = "You could change localization of application, read information about developer and read some features, which planned on near future".localized()
        default: break
        }
    }
    
    private func setupConstraints(){
        addSubview(footerView)
        footerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        footerView.addSubview(footerLabel)
        footerLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.trailing.equalToSuperview()
        }
    }

}
