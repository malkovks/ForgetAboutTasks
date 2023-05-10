//
//  AllTasksRealmManager.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 16.04.2023.
//

import RealmSwift
import Foundation

class AllTasksRealmManager {
    
    static let shared = AllTasksRealmManager()
    
    let localRealm = try! Realm()
    
    private init() {}
    
    func saveAllTasksModel(model: AllTaskModel){
        try! localRealm.write {
            localRealm.add(model)
        }
    }
    
    func changeCompleteStatus(model: AllTaskModel,boolean: Bool){
        try! localRealm.write {
            model.allTaskCompleted = boolean
        }
    }
    
    func editAllTasksModel(oldModelDate: String,newModel:AllTaskModel){
        let model = localRealm.objects(AllTaskModel.self).filter("allTaskNameEvent = %@",oldModelDate).first!
        try! localRealm.write {
            model.allTaskColor = newModel.allTaskColor 
            model.allTaskNameEvent = newModel.allTaskNameEvent 
            model.allTaskURL = newModel.allTaskURL ?? model.allTaskURL
            model.allTaskDate = newModel.allTaskDate ?? model.allTaskDate
            model.allTaskTime = newModel.allTaskTime ?? model.allTaskTime
            model.allTaskCompleted = newModel.allTaskCompleted
        }
    }
    
    
    func deleteAllTasks(model: AllTaskModel){
        try! localRealm.write {
            localRealm.delete(model)
        }
    }
    
    
    
}
