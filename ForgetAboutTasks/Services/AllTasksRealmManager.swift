//
//  AllTasksRealmManager.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 16.04.2023.
//

import RealmSwift

class AllTasksRealmManager {
    
    static let shared = AllTasksRealmManager()
    
    let localRealm = try! Realm()
    
    private init() {}
    
    func saveAllTasksModel(model: AllTaskModel){
        try! localRealm.write {
            localRealm.add(model)
            print("Tasks saved in realm")
        }
    }
    
    func changeAllTasksModel(model: AllTaskModel,boolean: Bool){
        try! localRealm.write {
            model.allTaskCompleted = boolean
        }
    }
    
    
    func deleteAllTasks(model: AllTaskModel){
        try! localRealm.write {
            localRealm.delete(model)
        }
    }
    
    
    
}
