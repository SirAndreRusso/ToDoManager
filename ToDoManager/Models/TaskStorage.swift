//
//  TaskStorage.swift
//  ToDoManager
//
//  Created by Андрей Русин on 15.06.2022.
//

import Foundation
protocol TaskStorageProtocol {
    func loadTasks () -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}
class TaskStorage: TaskStorageProtocol {
    func loadTasks() -> [TaskProtocol] {
        let testTasks: [TaskProtocol] = [Task(title: "Купить хлеб", type: .normal, status: .planned),
                                         Task(title: "Погладить кота", type: .important, status: .planned),
                                         Task(title: "Подумать о России", type: .normal, status: .planned),
                                         Task(title: "Полежать на диване", type: .important, status: .completed),
                                         Task(title: "Поспать до обеда", type: .important, status: .planned),
                                         Task(title: "Понюхать цветы", type: .normal, status: .planned),
                                         Task(title: "Посмотреть с загадочным видом в окно, сделать глубокий вдох, глотнуть кофе и одернуть занавеску", type: .important, status: .planned)]
        return testTasks
    }
    func saveTasks(_ tasks: [TaskProtocol]) {
        
    }
    
}
