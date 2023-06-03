//
//  ContactRealmManager.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.04.2023.
//

import Foundation
import RealmSwift

class ContactRealmManager {
    
    static let shared = ContactRealmManager()
    
    let localRealm = try! Realm()
    
    private init() {}
    
    func saveContactModel(model: ContactModel){
        try! localRealm.write {
            localRealm.add(model)
            print("Tasks saved in realm")
        }
    }
    
    func deleteContactModel(model: ContactModel){
        try! localRealm.write {
            localRealm.delete(model)
            print(model.contactID)
            print("Contact was deleted")
        }
    }
    
    func editAllTasksModel(user id: String,newModel:ContactModel){

        let model = localRealm.objects(ContactModel.self).filter("contactID == %@",id).first!
        try! localRealm.write {
            model.contactImage = newModel.contactImage ?? model.contactImage
            model.contactMail = newModel.contactMail ?? model.contactMail
            model.contactName = newModel.contactName ?? model.contactName
            model.contactPhoneNumber = newModel.contactPhoneNumber ?? model.contactPhoneNumber
            model.contactType = newModel.contactType ?? model.contactType
            print("Edit work fine")
        }
    }
    
    
}
