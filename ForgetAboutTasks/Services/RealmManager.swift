//
//  RealmManager.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 08.04.2023.
//

import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    
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
    
    func editScheduleModel(model: ScheduleModel,selected row: String){
        let results = localRealm.objects(ScheduleModel.self).filter("scheduleName == %@", row)
        guard var result = results.first else { return }
        try! localRealm.write {
            result = model
            print("Data was changed")
        }
    }
    
    
}
