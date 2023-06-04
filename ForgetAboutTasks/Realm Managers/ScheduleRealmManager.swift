//
//  ScheduleRealmManager.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 08.04.2023.
//

import RealmSwift
import Foundation

class ScheduleRealmManager {
    
    static let shared = ScheduleRealmManager()
    
    let localRealm = try! Realm()
    
    private init() {}
    
    func saveScheduleModel(model: ScheduleModel){
        try! localRealm.write {
            localRealm.add(model)
        }
    }
    
    func deleteScheduleModel(model: ScheduleModel){
        try! localRealm.write {
            localRealm.delete(model)
        }
    }

    func editScheduleModel(user id: String,changes: ScheduleModel){
        let model = localRealm.objects(ScheduleModel.self).filter("scheduleModelId == %@",id).first
        try! localRealm.write {
            model?.scheduleCategoryURL = changes.scheduleCategoryURL ?? model?.scheduleCategoryURL
            model?.scheduleCategoryName = changes.scheduleCategoryName ?? model?.scheduleCategoryName
            model?.scheduleCategoryNote = changes.scheduleCategoryNote ?? model?.scheduleCategoryNote
            model?.scheduleCategoryType = changes.scheduleCategoryType ?? model?.scheduleCategoryType
            model?.scheduleName = changes.scheduleName
            model?.scheduleDate = changes.scheduleDate ?? model?.scheduleDate
            model?.scheduleTime = changes.scheduleTime ?? model?.scheduleTime
            model?.scheduleColor = changes.scheduleColor ?? model?.scheduleColor
            model?.scheduleRepeat = ((changes.scheduleRepeat ?? model?.scheduleRepeat) != nil)
            model?.scheduleWeekday = changes.scheduleWeekday ?? model?.scheduleWeekday
            model?.scheduleImage = changes.scheduleImage ?? model?.scheduleImage
        }
    }
    
}
