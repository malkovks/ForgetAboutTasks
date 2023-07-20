//
//  UserProfileChangeAppFont.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 16.07.2023.
//

import UIKit
import SnapKit

protocol ChangeFontDelegate: AnyObject {
    func changeFont(font size: CGFloat,style: String)
}

class ChangeFontViewController: UIViewController {
    
    var dataReceive: ((CGFloat) -> Void)!
    private var rounderSize: CGFloat = CGFloat(UserDefaults.standard.float(forKey: "fontSizeChanging"))
    private var savedFontName: String = UserDefaults.standard.string(forKey: "fontNameChanging") ?? "Times New Roman"
    private let fontWeight: [UIFont.Weight] = [ UIFont.Weight.ultraLight,
                                         UIFont.Weight.thin,
                                         UIFont.Weight.light,
                                         UIFont.Weight.regular,
                                         UIFont.Weight.medium,
                                         UIFont.Weight.semibold,
                                         UIFont.Weight.bold,
                                         UIFont.Weight.heavy,
                                         UIFont.Weight.black]
    private let fontNames = UIFont.familyNames
    private var fontWeightString: [CGFloat] = []
    private var choosenFont: String = ""
    
    weak var delegate: ChangeFontDelegate?
    
    private let testFontLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "textColor")
        label.text = "Test font size and style: "
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let changeFontWeightLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "textColor")
        label.text = "Set weight font for table headers"
        label.numberOfLines = 2
        label.textAlignment = .center
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
    
    private let fontNamePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.tag = 0
        return picker
    }()
    
    private let fontWeightPicker: UIPickerView = {
       let picker = UIPickerView()
        picker.tag = 1
        return picker
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testFontLabel.text! += "\(rounderSize)"
        
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
    }
    
    @objc private func didTapDismiss(){
        self.dismiss(animated: true)
    }
    @objc private func didTapSave(){
        delegate?.changeFont(font: rounderSize, style: choosenFont)
        UserDefaults.standard.setValue(rounderSize, forKey: "fontSizeChanging")
        UserDefaults.standard.setValue(choosenFont, forKey: "fontNameChanging")
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    //MARK: - Setup methods
    private func setupView(){
        fontWeightString = getFontWeights(fonts: fontNames)
        setupFontSize()
        setupNavigation()
        view.backgroundColor = .systemBackground
        DispatchQueue.main.async {
            self.fontNamePicker.delegate = self
            self.fontNamePicker.dataSource = self
        }
    }
    
    private func setupFontSize(){
        let fontSize = Float(rounderSize)
        changeFontSlider.addTarget(self, action: #selector(didTapChangeFont), for: .valueChanged)
        changeFontSlider.value = fontSize
        if let index = fontNames.firstIndex(where: { $0 == savedFontName }) {
            fontNamePicker.selectRow(index, inComponent: 0, animated: true)
            testFontLabel.font = UIFont(name: savedFontName, size: rounderSize)
        }
        
    }
    
    private func setupNavigation(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", image: UIImage(systemName: "chevron.left"), target: self, action: #selector(didTapDismiss))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "navigationControllerColor")
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "navigationControllerColor")
    }
    
//    private func getFontsName(){
//        for name in fontNames {
//            let fonts = UIFont.fontNames(forFamilyName: name)
//            for n in fonts {
//                guard let font = UIFont(name: n, size: rounderSize) else { return  }
//                avaliableFonts.append(font)
//            }
//        }
//    }
    
    private func getFontWeights(fonts: [String]) -> [CGFloat]{
        var weights: [CGFloat] = []
        for weight in fontWeight {
            let fontTest = UIFont.systemFont(ofSize: 16,weight: weight)
            for font in fonts {
                if fontTest.familyName == font {
                    weights.append(weight.rawValue)
                }
            }
            
        }
        return weights
    }
    
}
//MARK: - Extension for UIPicker View delegate and data source
extension ChangeFontViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fontNames[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        testFontLabel.font = UIFont(name: fontNames[row], size: rounderSize)
        changeFontWeightLabel.font = UIFont(name: fontNames[row], size: rounderSize)
        choosenFont = fontNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = fontNames[row]
        label.font = UIFont(name: fontNames[row], size: 16)
        label.textAlignment = .center
        return label
    }
}
 //MARK: - Extension


extension ChangeFontViewController {
    private func setupConstraints(){
        view.addSubview(testFontLabel)
        testFontLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        view.addSubview(changeFontSlider)
        changeFontSlider.snp.makeConstraints { make in
            make.top.equalTo(testFontLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(50)
        }
        
        view.addSubview(fontNamePicker)
        fontNamePicker.snp.makeConstraints { make in
            make.top.equalTo(changeFontSlider.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(view.frame.size.height/4)
        }
        
//        view.addSubview(changeFontWeightLabel)
//        changeFontWeightLabel.snp.makeConstraints { make in
//            make.top.equalTo(fontNamePicker.snp.bottom)
//            make.leading.trailing.equalToSuperview().inset(10)
//            make.height.equalTo(30)
//        }
//
//        view.addSubview(fontWeightPicker)
//        fontWeightPicker.snp.makeConstraints { make in
//            make.top.equalTo(changeFontWeightLabel.snp.bottom)
//            make.leading.trailing.equalToSuperview().inset(10)
//            make.height.equalTo(view.frame.size.height/4)
//        }
    }
}
