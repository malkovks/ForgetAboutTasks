//
//  ScheduleRealmManager.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 08.04.2023.
//

import RealmSwift

class ScheduleRealmManager {
    
    static let shared = ScheduleRealmManager()
    
    let localRealm = try! Realm()
    
    private init() {}
    
    func saveScheduleModel(model: ScheduleModel){
        try! localRealm.write {
            localRealm.add(model)
            print("Data was saved in realm")
        }
    }
    
    func deleteScheduleModel(model: ScheduleModel){
        try! localRealm.write {
            localRealm.delete(model)
        }
    }

    func changeScheduleModel(model: ScheduleModel,changes: ScheduleModel){
        try! localRealm.write {
            model.scheduleCategoryURL = changes.scheduleCategoryURL
            model.scheduleCategoryName = changes.scheduleCategoryName
            model.scheduleCategoryNote = changes.scheduleCategoryNote
            model.scheduleCategoryType = changes.scheduleCategoryType
            model.scheduleName = changes.scheduleName
            model.scheduleDate = changes.scheduleDate
            model.scheduleTime = changes.scheduleTime
            model.scheduleColor = changes.scheduleColor
            model.scheduleRepeat = changes.scheduleRepeat
            model.scheduleWeekday = changes.scheduleWeekday
        }
    }
    
}
