//
//  UserProfileChangeAppFont.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 16.07.2023.
//

import UIKit
import SnapKit

var appFontSize = 20

class ChangeFontViewController: UIViewController {
    
    private let testFontLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor(named: "textColor")
        label.text = "Test font size!"
        return label
    }()
    
    private let changeFontSlider: UISlider = {
       let slider = UISlider()
        slider.minimumValue = 10
        slider.maximumValue = 40
        slider.isContinuous = true
        slider.minimumTrackTintColor = UIColor(named: "navigationControllerColor")
        slider.maximumTrackTintColor = UIColor(named: "navigationControllerColor")
        slider.thumbTintColor = UIColor(named: "textColor")
        slider.minimumValueImage = UIImage(systemName: "character")
        slider.maximumValueImage = UIImage(systemName: "character")
        slider.minimumValueImageRect(forBounds: CGRect(x: 1, y: 1, width: Int(slider.frame.size.width)/2, height: Int(slider.frame.size.height)/2))
        slider.maximumValueImageRect(forBounds: CGRect(x: 1, y: 1, width: Int(slider.frame.size.width), height: Int(slider.frame.size.height)))
        return slider
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let value = UserDefaults.standard.float(forKey: "fontSizeChanging")
        let fontSize = CGFloat(value)
        changeFontSlider.value = value
        testFontLabel.font = .systemFont(ofSize: fontSize)
        
        
        setupConstraints()
        setupView()
    }
    
    @objc private func didTapChangeFont(sender: UISlider){
        let fontSize = CGFloat(sender.value)
        testFontLabel.font = .systemFont(ofSize: fontSize)
        UserDefaults.standard.setValue(sender.value, forKey: "fontSizeChanging")
        
    }
    
    private func setupView(){
        view.backgroundColor = .systemBackground
        
        changeFontSlider.addTarget(self, action: #selector(didTapChangeFont), for: .valueChanged)
    }
}

extension ChangeFontViewController {
    private func setupConstraints(){
        view.addSubview(testFontLabel)
        testFontLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        view.addSubview(changeFontSlider)
        changeFontSlider.snp.makeConstraints { make in
            make.top.equalTo(testFontLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(50)
        }
    }
}
