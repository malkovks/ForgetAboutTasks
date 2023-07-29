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
        return view
    }()
    
    let contactImageView: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.image = UIImage(systemName: "person.crop.circle.badge.plus")?.withRenderingMode(.alwaysTemplate)
        image.tintColor = UIColor(named: "calendarHeaderColor")
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            make.top.bottom.equalToSuperview().inset(5)
            make.trailing.leading.equalToSuperview().inset(5)
        }
    }
}
