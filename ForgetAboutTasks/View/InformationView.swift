//
//  InformationView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.08.2023.
//

import UIKit

class InformationView: UIView {
    
    let customView: UIView = {
       let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor(named: "textColor")?.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.font = .setMainLabelFont()
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textColor = UIColor(named: "textColor")
        label.textAlignment = .justified
        return label
    }()
    
    let closeInfoViewButton: UIButton = {
        let button = UIButton(type: .close)
        button.layer.cornerRadius = button.frame.size.width/2
        button.backgroundColor = .clear
        button.tintColor = .green
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        closeInfoViewButton.addTarget(self, action: #selector(didTapCloseInfoView), for: .touchUpInside)
    }
    
    @objc private func didTapCloseInfoView(sender: UIButton){
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            UIView.animate(withDuration: 0.5,delay: 0) {
                self.customView.alpha = 0.0
                self.customView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            } completion: { success in
                self.customView.removeFromSuperview()
            }
        }
    }
    
    private func setupConstraints(){
        addSubview(customView)
        customView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        customView.addSubview(closeInfoViewButton)
        closeInfoViewButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.height.width.equalTo(15)
        }
        
        customView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(5)
        }
    }
    
    func setupLabelTextIndent(text: String){
        let paragraph = NSMutableParagraphStyle()
        paragraph.firstLineHeadIndent = 20
        
        let attributeString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraph])
        infoLabel.attributedText = attributeString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


extension UIViewController {
    func showInfoAuthentication(text: String, controller: UIView){
        let customView = InformationView()
        customView.setupLabelTextIndent(text: text)
        
        self.view.addSubview(customView)
        customView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().dividedBy(1.5)
            make.height.equalToSuperview().dividedBy(2)
        }
        
        UIView.animate(withDuration: 0.5) {
            customView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
    
    
    
    
}
