//
//  UserProfileTableViewCell.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 27.07.2023.
//

import UIKit


class UserProfileTableViewCell: UITableViewCell {
    
    static let identifier = "UserProfileTableViewCell"
    
   let cellImageView: UIImageView = {
       let image = UIImageView()
       image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
       image.sizeToFit()
       image.contentMode = .center
        return image
    }()
    
    private let mainTitleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = .setMainLabelFont()
        return label
    }()
    
    let switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.isOn = false
        switchButton.onTintColor = #colorLiteral(red: 0.3920767307, green: 0.5687371492, blue: 0.998278439, alpha: 1)
        switchButton.isHidden = true
        switchButton.clipsToBounds = true
        return switchButton
    }()
    
    let inclosureIndicator: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "arrow.right")
        image.tintColor = .darkGray
        image.contentMode = .scaleAspectFit
        image.isHidden = true
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContraints()
        self.selectionStyle = .blue
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    func configureCell(text: String,imageCell: UIImage,image tintColor: UIColor){
        mainTitleLabel.text = text
        cellImageView.image = imageCell
        cellImageView.tintColor = tintColor
    }

    func configureSwitch(indexPath: IndexPath){
        switch indexPath {
        case [0,0],[0,1],[0,2],[0,3],[0,4],[0,5],[1,2],[1,3]:
            switchButton.isHidden = false
            inclosureIndicator.isHidden = true
        case [0,6],[1,0],[1,1],[2,0],[2,1],[2,2],[3,0],[3,1]:
            inclosureIndicator.isHidden = false
            switchButton.isHidden = true
        default: break
        }
        
    }
    
    private func setupContraints(){
        contentView.addSubview(cellImageView)
        cellImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.width.height.equalTo(contentView.snp.height).inset(contentView.frame.size.height/2)
        }
    
        contentView.addSubview(mainTitleLabel)
        mainTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(cellImageView.snp.trailing).offset(5)
            make.top.bottom.equalToSuperview().inset(5)
        }
        
        contentView.addSubview(switchButton)
        switchButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        contentView.addSubview(inclosureIndicator)
        inclosureIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    
}
