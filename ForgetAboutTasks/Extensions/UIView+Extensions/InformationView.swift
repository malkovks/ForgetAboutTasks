//
//  InformationView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.08.2023.
//

import UIKit

class InformationVisualView: UIVisualEffectView {
    var isOpened: ((Bool) -> Void)?

    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.font = .setMainLabelFont()
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.textColor = UIColor(named: "textColor")
        label.textAlignment = .justified
        label.layer.cornerRadius = 12
        return label
    }()
    
    let closeInfoViewButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.imageView?.tintColor = UIColor(named: "loginColor")
        button.layer.cornerRadius = button.frame.size.width/2
        button.backgroundColor = .clear
        button.tintColor = .green
        return button
    }()

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        setupConstraints()
        setupVisualView()
        closeInfoViewButton.addTarget(self, action: #selector(didTapCloseInfoView), for: .touchUpInside)
    }
    
    @objc private func didTapCloseInfoView(sender: UIButton){
        UIView.animate(withDuration: 0.5,delay: 0) {
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { success in
            self.removeFromSuperview()
            self.isOpened?(false)
        }
    }
    
    private func setupVisualView(){
        let darkMode = UserDefaults.standard.bool(forKey: "setUserInterfaceStyle")
        let style = darkMode ? UIBlurEffect.Style.dark : UIBlurEffect.Style.light
        let visualView = UIBlurEffect(style: style)
        self.effect = visualView
        self.clipsToBounds = true
        self.layer.borderColor = UIColor(named: "textColor")?.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 12
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupLabelTextIndent(text: String){
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 20
        
        let attributeString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraph])
        infoLabel.attributedText = attributeString
    }
    //MARK: - Constraints
    private func setupConstraints(){
        
        contentView.addSubview(closeInfoViewButton)
        
        closeInfoViewButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.height.width.equalTo(15)
        }
        
        contentView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(5)
        }
    }
    
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    
    /// Function for showing custom view with information for user
    /// - Parameters:
    ///   - text: input text for displaying in view
    ///   - controller: super view where current view will add to subview
    /// - Returns: return boolean value if view was closed
    func showInfoAuthentication(text: String, controller: UIView) {
        let customView = InformationVisualView()
        customView.setupLabelTextIndent(text: text)
        
        self.view.addSubview(customView)
        customView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.4)
            make.height.equalToSuperview().dividedBy(2)
        }
        
        UIView.animate(withDuration: 0.5) {
            customView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
    
    
    
    
}
