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
    
    
    /// Saving All Tasks model to Realm Database
    /// - Parameter model: All Task Realm model
    func saveAllTasksModel(model: AllTaskModel){
        try! localRealm.write {
            localRealm.add(model)
            
        }
    }
    
    /// Function for sets status of event
    /// - Parameters:
    ///   - model: Status of chosen realm model
    ///   - boolean: boolean status of chosen model
    func changeCompleteStatus(model: AllTaskModel,boolean: Bool){
        try! localRealm.write {
            model.allTaskCompleted = boolean
        }
    }
    
    ///  Function for editing chosen model, full or partly edits
    /// - Parameters:
    ///   - oldModelDate: Date used as identifier
    ///   - newModel: this value set new edits if it not equal to nil
    func editAllTasksModel(oldModelDate: Date,newModel:AllTaskModel){
        let model = localRealm.objects(AllTaskModel.self).filter("allTaskDate == %@",oldModelDate).first!
        try! localRealm.write {
            model.allTaskColor = newModel.allTaskColor 
            model.allTaskNameEvent = newModel.allTaskNameEvent
            model.allTaskURL = newModel.allTaskURL ?? model.allTaskURL
            model.allTaskDate = newModel.allTaskDate ?? model.allTaskDate
            model.allTaskTime = newModel.allTaskTime ?? model.allTaskTime
            model.allTaskCompleted = newModel.allTaskCompleted
        }
    }
    
    
    /// Deleting current model from Database
    /// - Parameter model: model which need to delete
    func deleteAllTasks(model: AllTaskModel){
        try! localRealm.write {
            localRealm.delete(model)
        }
    }
    
    
    
}
