//
//  ScheduleTableViewCell.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 04.06.2023.
//

import UIKit
import SnapKit

class ScheduleTableViewCell: UITableViewCell {

    static let identifier = "ScheduleTableViewCell"
    
    let imageViewSchedule: UIImageView = {
       let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 10
        image.image = UIImage(systemName: "camera.fill")
        image.tintColor = UIColor(named: "navigationControllerColor")
        return image
    }()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        contentView.backgroundColor = UIColor(named: "cellColor")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    //MARK: - Downloading strings
    func configureImage(image model: ScheduleModel){
        guard let data = model.scheduleImage else { return }
        let image = UIImage(data: data)?.withRenderingMode(.automatic)
        imageViewSchedule.image = image
        
    }
}

extension ScheduleTableViewCell {
    private func setupConstraints(){
        contentView.addSubview(imageViewSchedule)
        imageViewSchedule.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}
