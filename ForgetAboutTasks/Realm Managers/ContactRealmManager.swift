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
    
    
    /// Function for saving created contact in Contact Database
    /// - Parameter model: Contact model
    func saveContactModel(model: ContactModel){
        try! localRealm.write {
            localRealm.add(model)
            print("Tasks saved in realm")
        }
    }
    
    /// Function for deleting chosen model
    /// - Parameter model: chosen model
    func deleteContactModel(model: ContactModel){
        try! localRealm.write {
            localRealm.delete(model)
        }
    }
    
    /// Deleting all  contacts from Database
    func deleteAllContactModel(){
        let objects = localRealm.objects(ContactModel.self)
        try! localRealm.write {
            localRealm.delete(objects)
        }
    }
    
    /// Editing contact parameters
    /// - Parameters:
    ///   - id: identifier for editing chosen value
    ///   - newModel: new value which checked if value changed, if not - assigning old value
    func editAllTasksModel(user id: String,newModel:ContactModel){

        let model = localRealm.objects(ContactModel.self).filter("contactID == %@",id).first!
        try! localRealm.write {
            model.contactImage = newModel.contactImage ?? model.contactImage
            model.contactMail = newModel.contactMail ?? model.contactMail
            model.contactName = newModel.contactName ?? model.contactName
            model.contactSurname = newModel.contactSurname ?? model.contactSurname
            model.contactCountry = newModel.contactCountry ?? model.contactCountry
            model.contactCity = newModel.contactCity ?? model.contactCity
            model.contactAddress = newModel.contactAddress ?? model.contactAddress
            model.contactPostalCode = newModel.contactPostalCode ?? model.contactPostalCode
            model.contactDateBirthday = newModel.contactDateBirthday ?? model.contactDateBirthday
            model.contactPhoneNumber = newModel.contactPhoneNumber ?? model.contactPhoneNumber
            model.contactType = newModel.contactType ?? model.contactType
        }
    }
    
    
}
