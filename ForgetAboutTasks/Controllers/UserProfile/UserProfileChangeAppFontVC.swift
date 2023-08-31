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
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private var savedFontSize: CGFloat = CGFloat(UserDefaults.standard.float(forKey: "fontSizeChanging"))
    private var savedFontName: String = UserDefaults.standard.string(forKey: "fontNameChanging") ?? "Times New Roman"
    private var savedFontWeight: CGFloat = CGFloat(UserDefaults.standard.float(forKey: "fontWeightChanging"))
    private lazy var fontWeight: [UIFont.Weight] = [
        UIFont.Weight.ultraLight,
        UIFont.Weight.thin,
        UIFont.Weight.light,
        UIFont.Weight.regular,
        UIFont.Weight.medium,
        UIFont.Weight.semibold,
        UIFont.Weight.bold,
        UIFont.Weight.heavy,
        UIFont.Weight.black
    ]
    private let fontNames = UIFont.familyNames
    private var fontWeightString: [String] = [
        "UltraLight",
        "Thin",
        "Light",
        "Regular",
        "Medium",
        "Semibold",
        "Bold",
        "Heavy",
        "Black"
    ]
    
    weak var delegate: ChangeFontDelegate?
    
    private let testFontLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "textColor")
        label.text = "Test font size and style: ".localized()
        
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let changeFontWeightLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "textColor")
        label.text = "Set weight font for table headers".localized()
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let headerForCollectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "textColor")
        label.text = "Set Weight for header title of Tables".localized()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = .setMainLabelFont()
        return label
    }()
    
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let changeFontSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 10
        slider.maximumValue = 20
        slider.isContinuous = true
        slider.minimumTrackTintColor = UIColor(named: "calendarHeaderColor")
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
    
    private let pageControl: UIPageControl = {
        let page = UIPageControl()
        page.pageIndicatorTintColor = UIColor(named: "calendarHeaderColor")
        page.currentPageIndicatorTintColor = UIColor(named: "navigationControllerColor")
        page.hidesForSinglePage = true
        return page
    }()
    
    private let saveFontSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Save changes".localized()
        button.configuration?.image = UIImage(systemName: "heart.circle.fill")
        button.configuration?.imagePadding = 2
        button.configuration?.imagePlacement = .trailing
        button.configuration?.baseBackgroundColor = UIColor(named: "calendarHeaderColor")
        button.configuration?.baseForegroundColor = UIColor(named: "calendarHeaderColor")
        return button
    }()
    
    private let returnDefaultFontSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .tinted()
        button.configuration?.title = "Default Settings"
        button.configuration?.image = UIImage(systemName: "gearshape.fill")
        button.configuration?.imagePadding = 2
        button.configuration?.imagePlacement = .trailing
        button.configuration?.baseBackgroundColor =  #colorLiteral(red: 1, green: 0.2012550235, blue: 0.1706680357, alpha: 1)
        button.configuration?.baseForegroundColor = UIColor(named: "textColor")
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    //MARK: - Target methods
    @objc private func didTapChangeFont(sender: UISlider){
        feedbackGenerator.selectionChanged()
        let interval = (changeFontSlider.maximumValue - changeFontSlider.minimumValue) / 5
        let fontSize = CGFloat(sender.value)
        let step = CGFloat(2)
        savedFontSize = round(fontSize / step) * step
        
        testFontLabel.font = .systemFont(ofSize: savedFontSize,weight: UIFont.Weight(rawValue: savedFontWeight))
        testFontLabel.text = "Test font size and style: ".localized() + String(describing: savedFontSize)
        let section = Int(floor(sender.value / interval))
        sender.value = Float(section) * interval
    }
    
    @objc private func didTapDismiss(){
        setupHapticMotion(style: .soft)
        self.dismiss(animated: isViewAnimated)
    }
    @objc private func didTapSave(){
        setupHapticMotion(style: .soft)
        delegate?.changeFont(font: savedFontSize, style: savedFontName)
        UserDefaults.standard.setValue(savedFontSize, forKey: "fontSizeChanging")
        UserDefaults.standard.setValue(savedFontName, forKey: "fontNameChanging")
        UserDefaults.standard.setValue(savedFontWeight, forKey: "fontWeightChanging")
        DispatchQueue.main.async {
            self.dismiss(animated: isViewAnimated)
        }
    }
    
    @objc private func didTapReturnDefaultSettings(){
        setupHapticMotion(style: .heavy)
        let alert = UIAlertController(title: "Warning".localized(), message: "Do you want to set font settings to default?".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Apply".localized(), style: .destructive,handler: { _ in
            UserDefaults.standard.setValue(16, forKey: "fontSizeChanging")
            UserDefaults.standard.setValue("Didot", forKey: "fontNameChanging")
            UserDefaults.standard.setValue(0.0, forKey: "fontWeightChanging")
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.dismiss(animated: isViewAnimated)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        self.present(alert, animated: isViewAnimated)
    }
    
    //MARK: - Setup methods
    private func setupView(){
        
        
        setupConstraints()
        setupCollectionView()
        setupFontSize()
        setupNavigation()
        setupPageControll()
        view.backgroundColor = .systemBackground
        DispatchQueue.main.async {
            self.fontNamePicker.delegate = self
            self.fontNamePicker.dataSource = self
        }
    }
    
    private func setupPageControll(){
        pageControl.numberOfPages = 5
    }
    
    private func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: view.frame.size.width/2-20, height: 30)
    

        collectionView.setCollectionViewLayout(layout, animated: isViewAnimated)
        collectionView.register(UserProfileFontCollectionViewCell.self, forCellWithReuseIdentifier: UserProfileFontCollectionViewCell.identifier)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.allowsMultipleSelection = true
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func setupFontSize(){
        let fontSize = Float(savedFontSize)
        changeFontSlider.addTarget(self, action: #selector(didTapChangeFont), for: .valueChanged)
        changeFontSlider.value = fontSize
        
        testFontLabel.text! += "\(savedFontSize)"
        testFontLabel.font = UIFont(name: savedFontName, size: savedFontSize)
        testFontLabel.font = .systemFont(ofSize: savedFontSize, weight: UIFont.Weight(rawValue: savedFontWeight))
        
        headerForCollectionLabel.font = UIFont(name: savedFontName, size: savedFontSize)
        headerForCollectionLabel.font = .systemFont(ofSize: savedFontSize, weight: UIFont.Weight(rawValue: savedFontWeight))
        saveFontSettingsButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        returnDefaultFontSettingsButton.addTarget(self, action: #selector(didTapReturnDefaultSettings), for: .touchUpInside)
        
        if let index = fontNames.firstIndex(where: { $0 == savedFontName }) {
            fontNamePicker.selectRow(index, inComponent: 0, animated: isViewAnimated)
            testFontLabel.font = .setMainLabelFont()
        }
    }
    
    private func setupNavigation(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized(), style: .done, target: self, action: #selector(didTapSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back".localized(), image: UIImage(systemName: "chevron.down"), target: self, action: #selector(didTapDismiss))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "calendarHeaderColor")
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "calendarHeaderColor")
    }
}
extension ChangeFontViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fontWeightString.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileFontCollectionViewCell.identifier, for: indexPath) as? UserProfileFontCollectionViewCell
        let weight = fontWeight[indexPath.row]
        let nameWeight = fontWeightString[indexPath.row]
        cell?.configureCell(withFont: weight, size: savedFontSize, style: savedFontName, weightName: nameWeight)
        cell?.backgroundColor = UIColor(named: "calendarHeaderColor")
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setupHapticMotion(style: .soft)
        let fontWeight = fontWeight[indexPath.row]
        testFontLabel.font = UIFont(name: savedFontName, size: savedFontSize)
        testFontLabel.font = .systemFont(ofSize: savedFontSize, weight: fontWeight)
        savedFontWeight = fontWeight.rawValue
        savedFontName = "Times New Roman"
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = currentPage
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
        let fontName = fontNames[row]
        testFontLabel.font = UIFont(name: fontName, size: savedFontSize)
        savedFontName = fontNames[row]
        savedFontWeight = 0.0
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
        
        view.addSubview(headerForCollectionLabel)
        headerForCollectionLabel.snp.makeConstraints { make in
            make.top.equalTo(changeFontSlider.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerForCollectionLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(50)
        }
        
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
    
        view.addSubview(fontNamePicker)
        fontNamePicker.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(view.frame.size.height/4)
        }
        
        view.addSubview(saveFontSettingsButton)
        saveFontSettingsButton.snp.makeConstraints { make in
            make.top.equalTo(fontNamePicker.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(40)
        }
        
        view.addSubview(returnDefaultFontSettingsButton)
        returnDefaultFontSettingsButton.snp.makeConstraints { make in
            make.top.equalTo(saveFontSettingsButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(40)
        }
    }
}
