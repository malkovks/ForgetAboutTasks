//
//  OptionsTableViewCell.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 02.04.2023.
//

import UIKit
import SnapKit

class OptionsTableViewCell: UITableViewCell {
    
    static let identifier = "OptionsTableViewCell"
    
    
    var cellsName = [["Name of event"],
                     ["Date", "Time"],
                     ["Name","Type","URL","Note"],
                     [""],
                     ["Repeat every 7 days"]]
    //MARK: - UI setups
    
    let switchButton: UISwitch = {
       let _switch = UISwitch()
        _switch.isOn = true
        _switch.isHidden = true
        _switch.onTintColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        return _switch
    }()
    
    let backgroundViewCell: UIView = {
       let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        return view
        
    }()
    
    let nameCellLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = "cell"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        self.selectionStyle = .blue
        self.backgroundColor = .clear
        
        switchButton.addTarget(self, action: #selector(didTapSwitchCange(target:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(indexPath: IndexPath){
        nameCellLabel.text = cellsName[indexPath.section][indexPath.row]
        
        if indexPath == [3,0] {
            backgroundViewCell.backgroundColor = #colorLiteral(red: 0.6633207798, green: 0.6751670241, blue: 1, alpha: 1)
        }
        
        if indexPath == [4,0] {
            switchButton.isHidden = false
        }
    }
    
    @objc private func didTapSwitchCange(target: UISwitch) {
        if target.isOn {
            print("On")
        } else {
            print("Off")
        }
    }

}

extension OptionsTableViewCell {
    private func setupConstraints(){
        self.addSubview(backgroundViewCell)
        backgroundViewCell.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.trailing.equalToSuperview().inset(5)
        }
        
        self.addSubview(nameCellLabel)
        nameCellLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(contentView.frame.size.width/2)
        }
        
        self.addSubview(switchButton)
        switchButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(backgroundViewCell.snp.trailing).offset(-20)
        }
    }
}


