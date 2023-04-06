//
//  CreateTaskModel.swift
//  ForgetAboutTasks
//
//  Created by Константин Малков on 05.04.2023.
//

import UIKit

protocol TasksViewDelegate: AnyObject {
    func tasksData(array data: [TasksDate],date: String)
}

struct TasksDate {
    var date: String
    var dateGetter: Date?
    var startDate: String?
    var endDate: String?
    var name: String
}
