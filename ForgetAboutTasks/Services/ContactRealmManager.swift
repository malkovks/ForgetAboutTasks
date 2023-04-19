//
//  ContactRealmManager.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.04.2023.
//

import RealmSwift

class ContactRealmManager {
    
    static let shared = ContactRealmManager()
    
    let localRealm = try! Realm()
    
    private init() {}
    
    func saveScheduleModel(model: ContactModel){
        try! localRealm.write {
            localRealm.add(model)
            print("Tasks saved in realm")
        }
    }
    
    func deleteScheduleModel(model: ContactModel){
        try! localRealm.write {
            localRealm.delete(model)
            print("Contact was deleted")
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
