//
//  UserProfileHeaderView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 27.07.2023.
//

import UIKit

///Custom view for displaying in Header of UserProfileViewController UITableView
class UserProfileHeaderView: UIView {
    
    let headerView: UIView = {
       let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let headerLabel: UILabel = {
       let label = UILabel()
        label.textColor = UIColor(named: "textColor")
        label.textAlignment = .left
        label.font = .setMainLabelFont()
        return label
        
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Setup text of label
    /// - Parameter section: input indexPath.section from tableView
    func setupText(indexPath section: Int){
        switch section {
        case 0: headerLabel.text = "Main setups".localized()
        case 1: headerLabel.text = "Security settings".localized()
        case 2: headerLabel.text = "Secondary setups".localized()
        case 3: headerLabel.text = "Info".localized()
        case 4: headerLabel.text = "Account settings".localized()
        default: break
        }
    }
    
    private func setupConstraints(){
        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        headerView.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().offset(5)
            make.leading.trailing.equalToSuperview().inset(15)
        }
    }
    
}
