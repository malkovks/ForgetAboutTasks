//
//  NewContactCustomView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 06.04.2023.
//

import UIKit
import SnapKit

class NewContactCustomView: UIView {
    
    let viewForImage: UIView = {
       let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        view.layer.cornerRadius = 10
        return view
    }()
    
    let contactImageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.image = UIImage(systemName: "person.crop.circle.badge.plus")?.withRenderingMode(.alwaysTemplate)
        image.tintColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        image.layer.cornerRadius = 10
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupTargetForImage()
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTargetForImage(){
        
    }
    
}

extension NewContactCustomView {
    private func setupConstraints(){
        self.addSubview(viewForImage)
        viewForImage.snp.makeConstraints { make in
            make.top.trailing.leading.bottom.equalToSuperview()
        }
        viewForImage.addSubview(contactImageView)
        contactImageView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.leading.equalToSuperview()
        }
    }
}
