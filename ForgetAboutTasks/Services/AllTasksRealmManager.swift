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
    
    func changeAllTasksModel(model: AllTaskModel){
        try! localRealm.write {
            
        }
    }
    
    
    func deleteAllTasks(model: AllTaskModel){
        try! localRealm.write {
            localRealm.delete(model)
        }
    }
    
//    func editScheduleModel(model: ScheduleModel,selected row: String){
//        let results = localRealm.objects(ScheduleModel.self).filter("scheduleName == %@", row)
//        guard var result = results.first else { return }
//        try! localRealm.write {
//            result = model
//            print("Data was changed")
//        }
//    }
    
    
}
