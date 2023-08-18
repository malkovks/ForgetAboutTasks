//
//  InformationView.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.08.2023.
//

import UIKit



class InformationView: UIViewController {
    
    let infoView = UIView()
    
    let infoLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewConstraints()
    }
    
    private func setupView(){
        infoView.backgroundColor = .yellow
        infoLabel.text = "Сегодня мы с вами создали простое приложение с возможностью снимать на фронталку и заднюю камеры, а также со вспышкой и зумом. Этого материала должно хватить на то чтобы ввести в курс дела тех, кто только начал работу с AVFoundation. Буду благодарен любому фидбэку, спасибо за внимание."
        infoLabel.font = .setMainLabelFont()
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.backgroundColor = .red
    }
    
    private func setupViewConstraints(){
        view.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.width.equalToSuperview().multipliedBy(2/3)
            make.height.equalToSuperview().dividedBy(2)
        }
        
        infoView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    

}
