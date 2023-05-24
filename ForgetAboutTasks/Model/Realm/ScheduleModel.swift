//
//  ScheduleModel.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 08.04.2023.
//

import RealmSwift
import Foundation

class ScheduleModel: Object {
    @Persisted var scheduleDate: Date? //до этого было базовое свойство
    @Persisted var scheduleTime: Date? //до этого было базовое свойство
    @Persisted var scheduleName: String
    @Persisted var scheduleCategoryName: String?
    @Persisted var scheduleCategoryType: String?
    @Persisted var scheduleCategoryURL: String?
    @Persisted var scheduleCategoryNote: String?
    @Persisted var scheduleColor: Data? 
    @Persisted var scheduleRepeat: Bool? = false
    @Persisted var scheduleWeekday: Int?   
}

