//
//  ContactModel.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 19.04.2023.
//

import UIKit
import RealmSwift

class ContactModel: Object {
    
    @Persisted var contactName: String = "Unknown"
    @Persisted var contactPhoneNumber: String = "Unknown"
    @Persisted var contactMail: String = "Unknown"
    @Persisted var contactType: String = "Unknown"
    @Persisted var contactImage: Data?
}
