//
//  SetTimeViewController.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 22.03.2023.
//

import UIKit
import SnapKit

class SetTimeViewController: UIViewController {

    
    let timeView = SetTimeView()
    
    weak var delegate: SetTimeProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setConstraints()
        setupNavigation()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if navigationController == nil {
            print("dissapear")
        }
    }
    
    @objc private func didTapDismiss(){
//        let date = timeView.timePicker.date
//        var calendar = Calendar.current
//        
//        let components = calendar.dateComponents([.hour, .minute], from: date)
//        let result = String(describing: components.hour ?? 0) + "-" + String(describing: components.minute ?? 0)
//        delegate?.timePicker(sendTime: result)
        self.dismiss(animated: true)
    }
    
    private func setupNavigation(){
        title = "Setting up Time"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
    }
}

extension SetTimeViewController {
    private func setConstraints(){
        view.addSubview(timeView)
        timeView.layer.cornerRadius = 8
        timeView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(5)
            make.height.equalTo(view.frame.size.height/4.5)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            
        }
    }
    
}
