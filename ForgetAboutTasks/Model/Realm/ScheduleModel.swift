//
//  ScheduleModel.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 08.04.2023.
//

import RealmSwift
import Foundation

class ScheduleModel: Object {
    @Persisted var scheduleDate = Date()
    @Persisted var scheduleTime = Date()
    @Persisted var scheduleName: String = ""
    @Persisted var scheduleCategoryName: String = ""
    @Persisted var scheduleCategoryType: String = ""
    @Persisted var scheduleCategoryURL: String = ""
    @Persisted var scheduleCategoryNote: String = ""
    @Persisted var scheduleColor: String = "9999CC" //по этому вопрос, тк  мы делаем разные цвета
    @Persisted var scheduleRepeat: Bool = true
    @Persisted var scheduleWeekday: Int = 1
    
}

