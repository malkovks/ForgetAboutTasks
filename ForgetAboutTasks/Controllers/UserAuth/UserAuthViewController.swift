//
//  UserAuthViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 24.03.2023.
//

import UIKit
import SnapKit

class UserAuthViewController: UIViewController {
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = "Log in"
        label.backgroundColor = .systemRed
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView(){
        setupNavigation()
        setupConstraints()
        view.backgroundColor = #colorLiteral(red: 0.6571951509, green: 0.9842060208, blue: 1, alpha: 1)
    }
    
    private func setupNavigation(){
        
    }
    
    
}

extension UserAuthViewController {
    private func setupConstraints(){
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(55)
            
        }
    }
}
