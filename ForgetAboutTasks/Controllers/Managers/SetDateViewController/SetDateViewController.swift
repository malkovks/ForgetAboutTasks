//
//  SetDateViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 22.03.2023.
//

import UIKit
import SnapKit

class SetDateViewController: UIViewController {

    
    let dateView = SetDateView()
    
    weak var delegate: SetDateProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setConstraints()
        setupNavigation()
        
    }
    
    @objc private func didTapDismiss(){
        let date = dateView.calendarPicker.date
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.day,.month,.year], from: date)
        let result = "\(comp.day ?? 0).\(comp.month ?? 0).\(comp.year ?? 0)"
        delegate?.datePicker(sendDate: result)
        self.dismiss(animated: true)
    }
    
    private func setupNavigation(){
        title = "Setting up Date"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
    }


}

extension SetDateViewController {
    private func setConstraints(){
        view.addSubview(dateView)
        dateView.layer.cornerRadius = 8
        dateView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(5)
            make.height.equalTo(view.frame.size.height/2)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            
        }
    }
    
}
