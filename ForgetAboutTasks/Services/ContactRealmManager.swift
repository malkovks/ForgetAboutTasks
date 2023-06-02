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
            print("Contact was deleted")
        }
    }
    
    func editAllTasksModel(filter phoneNumber: String,secondFilter contactName: String,newModel:ContactModel?){
        let predicate = NSPredicate(format: "contactName == %@", contactName)
        let secondPredicate = NSPredicate(format: "contactPhoneNumber == %@", phoneNumber)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,secondPredicate])
        let model = localRealm.objects(ContactModel.self).filter(compoundPredicate).first!
        try! localRealm.write {
            model.contactImage = newModel?.contactImage ?? model.contactImage
            model.contactMail = newModel?.contactMail ?? model.contactMail
            model.contactName = newModel?.contactName ?? model.contactName
            model.contactPhoneNumber = newModel?.contactPhoneNumber ?? model.contactPhoneNumber
            model.contactType = newModel?.contactType ?? model.contactType
        }
    }
    
    
}
