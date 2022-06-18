//
//  tableTableViewController.swift
//  ToDoManager
//
//  Created by Андрей Русин on 15.06.2022.
//

import UIKit

class TaskListController: UITableViewController {
    var tasksStorage: TaskStorageProtocol = TaskStorage()
    var tasks: [TaskPriority: [TaskProtocol]] = [:] {
        didSet {
            for (tasksGroupPriority, tasksGroup) in tasks {
                tasks[tasksGroupPriority] = tasksGroup.sorted {task1, task2 in
                    let task1Position = taskStatusPosition.firstIndex(of: task1.status)
                    ?? 0
                    let task2Position = taskStatusPosition.firstIndex(of: task2.status)
                    ?? 0
                    return task1Position < task2Position
                }
            }
        }
    }
    var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
    var taskStatusPosition: [TaskStatus] = [.planned, .completed]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()
        //Добавляем кнопку Edit для вьюконтроллера, позволяющую редактировать таблицу
        navigationItem.leftBarButtonItem = editButtonItem
    }
    private func loadTasks () {
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        tasksStorage.loadTasks().forEach { task in
            tasks[task.type]?.append(task)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let tasksType = sectionsTypesPosition[section]
        if tasksType == .important {
            title = "Важные"
        } else if tasksType == .normal {
            title = "Текущие"
        }
        return title
    }
    
    
    
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let taskType = sectionsTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else {return 0}
        return currentTasksType.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getConfiguredTaskCell_constraints(for: indexPath)
        //        return getConfiguredTaskCell_stack(for: indexPath)
    }
    
    // Доступ к прототипу яйчейки, созданному с помощью констрэйнтов и с доступом по тэгу
    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            
            return cell
        }
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        let textLabel = cell.viewWithTag(2) as? UILabel
        symbolLabel?.text = getSymbolForTask(with:currentTask.status)
        textLabel?.text = currentTask.title
        if currentTask.status == .planned {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        return cell
    }
    // Доступ к прототипу яйчейки, созданному с помощью StackView, и с доступом через кастомный класс TaskCell
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            
            return cell
        }
        cell.title.text = currentTask.title
        cell.symbol.text = getSymbolForTask(with:currentTask.status)
        
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        return cell
    }
    
    
    
    
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        return resultSymbol
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row]
        else {
            return
        }
        guard tasks[taskType]![indexPath.row].status == .planned
        else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        tasks[taskType]![indexPath.row].status = .completed
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row]
        else {
            return nil
        }
        guard tasks[taskType]![indexPath.row].status == .completed
        else {
            return nil
        }
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Не выполнена") {_,_,_ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        return UISwipeActionsConfiguration(actions: [actionSwipeInstance])
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        tasks[taskType]?.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
        let taskTypeto = sectionsTypesPosition[destinationIndexPath.section]
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row]
        else {
            return
        }
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        tasks[taskTypeto]!.insert(movedTask, at: destinationIndexPath.row)
        if taskTypeFrom != taskTypeto {
            tasks[taskTypeto]![destinationIndexPath.row].type = taskTypeto
        }
        tableView.reloadData()
    }
}
