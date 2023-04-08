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
    
    
}
