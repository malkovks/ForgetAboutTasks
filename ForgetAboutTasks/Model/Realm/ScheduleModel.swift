//
//  ScheduleModel.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 08.04.2023.
//

import RealmSwift
import Foundation

class ScheduleModel: Object {
    @Persisted var scheduleModelId = UUID().uuidString
    @Persisted var scheduleStartDate: Date?
    @Persisted var scheduleTime: Date?
    @Persisted var scheduleEndDate: Date?
    @Persisted var scheduleName: String?
    @Persisted var scheduleCategoryName: String?
    @Persisted var scheduleCategoryType: String?
    @Persisted var scheduleCategoryURL: String?
    @Persisted var scheduleCategoryNote: String?
    @Persisted var scheduleImage: Data?
    @Persisted var scheduleColor: Data? 
    @Persisted var scheduleActiveNotification: Bool? = false
    @Persisted var scheduleActiveCalendar: Bool? = false
    @Persisted var scheduleWeekday: Int?   
}

