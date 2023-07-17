//
//  UserProfileChangeAppFont.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 16.07.2023.
//

import UIKit
import SnapKit

protocol ChangeFontDelegate: AnyObject {
    func changeFont(font size: CGFloat)
}

class ChangeFontViewController: UIViewController {
    
    var dataReceive: ((CGFloat) -> Void)!
    private var rounderSize: CGFloat = CGFloat(UserDefaults.standard.float(forKey: "fontSizeChanging"))
    
    weak var delegate: ChangeFontDelegate?
    
    private let testFontLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor(named: "textColor")
        label.text = "Test font size: "
        return label
    }()
    
    private let changeFontSlider: UISlider = {
       let slider = UISlider()
        slider.minimumValue = 8
        slider.maximumValue = 20
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
        
        
        setupConstraints()
        setupView()
    }
    //MARK: - Target methods
    @objc private func didTapChangeFont(sender: UISlider){
        let fontSize = CGFloat(sender.value)
        let step = CGFloat(2)
        rounderSize = round(fontSize / step) * step
        
        testFontLabel.font = .systemFont(ofSize: rounderSize)
        testFontLabel.text = "Test font size: \(rounderSize)"
        UserDefaults.standard.setValue(rounderSize, forKey: "fontSizeChanging")
    }
    
    @objc private func didTapDismiss(){
        delegate?.changeFont(font: rounderSize)
        dismiss(animated: true)
    }
    //MARK: - Setup methods
    private func setupView(){
        view.backgroundColor = .systemBackground
        let fontSize = Float(rounderSize)
        changeFontSlider.addTarget(self, action: #selector(didTapChangeFont), for: .valueChanged)
        changeFontSlider.value = fontSize
        testFontLabel.font = .systemFont(ofSize: rounderSize)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", image: UIImage(systemName: "chevron.left"), target: self, action: #selector(didTapDismiss))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "navigationControllerColor")
    }
    
 //MARK: - Extension
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
