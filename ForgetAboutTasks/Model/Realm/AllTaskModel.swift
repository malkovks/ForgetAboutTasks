//
//  AllTaskModel.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 16.04.2023.
//

import RealmSwift
import Foundation

class AllTaskModel: Object {
    
    @Persisted var allTaskNameEvent: String
    @Persisted var allTaskDate: Date?
    @Persisted var allTaskTime: Date?
    @Persisted var allTaskNotes: String = "Unknown datqa"
    @Persisted var allTaskURL: String = "Unknown URL"
    @Persisted var allTaskColor: Data?
    @Persisted var allTaskCompleted: Bool = false
}
