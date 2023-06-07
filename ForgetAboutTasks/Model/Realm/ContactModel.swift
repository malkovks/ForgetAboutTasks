//
//  ContactModel.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.04.2023.
//

import UIKit
import RealmSwift

class ContactModel: Object {
    
    @Persisted var contactID: String = UUID().uuidString
    @Persisted var contactName: String?
    @Persisted var contactSurname: String?
    @Persisted var contactCountry: String?
    @Persisted var contactCity: String?
    @Persisted var contactAddress: String?
    @Persisted var contactPostalCode: String?
    @Persisted var contactPhoneNumber: String?
    @Persisted var contactMail: String?
    @Persisted var contactType: String?
    @Persisted var contactImage: Data?
    @Persisted var contactDateBirthday: Date?
}
