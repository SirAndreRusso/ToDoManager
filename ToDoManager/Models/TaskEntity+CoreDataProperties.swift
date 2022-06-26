//
//  TaskEntity+CoreDataProperties.swift
//  ToDoManager
//
//  Created by Андрей Русин on 25.06.2022.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var type: Int32
    @NSManaged public var status: Int32

}

extension TaskEntity : Identifiable {

}

extension TaskEntity {
    var taskPriority: TaskPriority {
        get {
            return TaskPriority(rawValue: self.type)!
        }
        set {
            self.type = newValue.rawValue
        }
    }
}

extension TaskEntity {
    var taskStatus: TaskStatus {
        get {
            return TaskStatus(rawValue: self.status)!
        }
        set {
            self.status = newValue.rawValue
        }
    }
}
