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
        DispatchQueue.main.async {
            try! self.localRealm.write {
                self.localRealm.add(model)
            }
        }
    }
    
    func deleteScheduleModel(model: ScheduleModel){
        try! localRealm.write {
            localRealm.delete(model)
        }
    }

    func editScheduleModel(user id: String,changes: ScheduleModel){
        DispatchQueue.main.async {
            let model = self.localRealm.objects(ScheduleModel.self).filter("scheduleModelId == %@",id).first
            try! self.localRealm.write {
                model?.scheduleCategoryURL = changes.scheduleCategoryURL ?? model?.scheduleCategoryURL
                model?.scheduleCategoryName = changes.scheduleCategoryName ?? model?.scheduleCategoryName
                model?.scheduleCategoryNote = changes.scheduleCategoryNote ?? model?.scheduleCategoryNote
                model?.scheduleCategoryType = changes.scheduleCategoryType ?? model?.scheduleCategoryType
                model?.scheduleName = changes.scheduleName
                model?.scheduleStartDate = changes.scheduleStartDate ?? model?.scheduleStartDate
                model?.scheduleEndDate = changes.scheduleEndDate ?? model?.scheduleEndDate
                model?.scheduleTime = changes.scheduleTime ?? model?.scheduleTime
                model?.scheduleColor = changes.scheduleColor ?? model?.scheduleColor
                model?.scheduleActiveCalendar = changes.scheduleActiveCalendar ?? model?.scheduleActiveCalendar
                model?.scheduleActiveNotification = changes.scheduleActiveNotification ?? model?.scheduleActiveNotification
                model?.scheduleWeekday = changes.scheduleWeekday ?? model?.scheduleWeekday
                model?.scheduleImage = changes.scheduleImage ?? model?.scheduleImage
                self.localRealm.autorefresh = false
            }
        }
        
    }
    
}
