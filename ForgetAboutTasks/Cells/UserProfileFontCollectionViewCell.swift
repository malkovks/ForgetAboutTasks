//
//  UserProfileFontCollectionView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 25.07.2023.
//

import UIKit

class UserProfileFontCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "UserProfileFontCollectionViewCell"
    
    private let fontStyleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupConstraints()
        self.backgroundColor = .clear
        self.contentView.layer.cornerRadius = 12
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupConstraints(){
        addSubview(fontStyleLabel)
        fontStyleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        }
    }
    
    func configureCell(withFont weight: UIFont.Weight, size: CGFloat, style: String,weightName: String) {
        fontStyleLabel.textColor = UIColor(named: "textColor")
        fontStyleLabel.font = .systemFont(ofSize: size, weight: weight)
        fontStyleLabel.text = weightName
    }
}
