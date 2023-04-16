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
    @Persisted var scheduleName: String = "Unknown"
    @Persisted var scheduleCategoryName: String = ""
    @Persisted var scheduleCategoryType: String = ""
    @Persisted var scheduleCategoryURL: String = ""
    @Persisted var scheduleCategoryNote: String = ""
    @Persisted var scheduleColor: Data? //по этому вопрос, тк  мы делаем разные цвета
    @Persisted var scheduleRepeat: Bool = false
    @Persisted var scheduleWeekday: Int = 1
    
}

