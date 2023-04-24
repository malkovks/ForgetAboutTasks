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
        
//        let mainModel =  localRealm.objects(AllTaskModel.self)
//        let taskModel = mainModel[index]
//        if boolean == true {
//            try! localRealm.write {
//                taskModel.allTaskCompleted = false
//                print("value was changed to false")
//            }
//        } else if boolean == false {
//            try! localRealm.write {
//                taskModel.allTaskCompleted = true
//                print("value was cnanged to true")
//            }
//        }
        
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
