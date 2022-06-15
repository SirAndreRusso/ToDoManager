//
//  Task.swift
//  ToDoManager
//
//  Created by Андрей Русин on 15.06.2022.
//

import Foundation
protocol TaskProtocol {
    var title: String {get set}
    var type: TaskPriority {get set}
    var status: TaskStatus {get set}
}
struct Task: TaskProtocol {
    var title: String
    
    var type: TaskPriority
    
    var status: TaskStatus
    
    
}

enum TaskPriority {
    case normal
    case important
}

enum TaskStatus {
    case planned
    case completed
}
