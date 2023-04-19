//
//  ContactModel.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.04.2023.
//

import UIKit
import RealmSwift

class ContactModel: Object {
    
    @Persisted var contactName: String
    @Persisted var contactPhoneNumber: String
    @Persisted var contactMail: String
    @Persisted var contactType: String
    @Persisted var contactImage: Data?
}
