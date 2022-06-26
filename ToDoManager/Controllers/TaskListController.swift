//
//  tableTableViewController.swift
//  ToDoManager
//
//  Created by Андрей Русин on 15.06.2022.
//

import UIKit
import CoreData

class TaskListController: UITableViewController {
    var dataStoreManager = DataStoreManager()
//    var tasksStorage: TaskStorageProtocol = TaskStorage()
    var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
    var taskStatusPosition: [TaskStatus] = [.planned, .completed]
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
       
        //Добавляем кнопку Edit для вьюконтроллера, позволяющую редактировать таблицу
        navigationItem.leftBarButtonItem = editButtonItem
        
        //  Для добавления долгого нажатия
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(longPressGestureRecognizer:)))
                    self.view.addGestureRecognizer(longPressRecognizer)
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTasks()
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = {[unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }
    
    private func loadTasks () {
            sectionsTypesPosition.forEach { taskType in
                tasks[taskType] = []
            }
        let context = dataStoreManager.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let entities = try context.fetch(fetchRequest)
            
            for entity in entities {
                let task: TaskProtocol = Task(title: entity.title!, type: entity.taskPriority, status: entity.taskStatus)
                tasks[task.type]?.append(task)
                tableView.reloadData()
            }
            
        } catch let error as NSError {
            print(error)
        }
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint)  {
                
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
                           let completeTaskAlert = UIAlertController(title: "Внимание", message: "Вы действительно хотите завершить задачу?", preferredStyle: .alert)
                           let completeTaskAction = UIAlertAction(title: "Завершить", style: .default){ _ in
                               self.tasks[taskType]![indexPath.row].status = .completed
                               self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
                           }
                               let cancelAction = UIAlertAction(title: "Отмена", style: .default)
                               completeTaskAlert.addAction(completeTaskAction)
                               completeTaskAlert.addAction(cancelAction)
                           self.present(completeTaskAlert, animated: true)
                           }

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
        guard let currentTasksType = tasks[taskType]
        else {
            return 0}
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
    
    
//Функционал завершения выбранной задачи переехал из метода didSelectRowAt в метод longPress
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let taskType = sectionsTypesPosition[indexPath.section]
//        guard let _ = tasks[taskType]?[indexPath.row]
//        else {
//            return
//        }
//        guard tasks[taskType]![indexPath.row].status == .planned
//        else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
//        }
//        let completeTaskAlert = UIAlertController(title: "Внимание", message: "Вы действительно хотите завершить задачу?", preferredStyle: .alert)
//        let completeTaskAction = UIAlertAction(title: "Завершить", style: .default){ _ in
//            self.tasks[taskType]![indexPath.row].status = .completed
//        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
//        }
//            let cancelAction = UIAlertAction(title: "Отмена", style: .default)
//            completeTaskAlert.addAction(completeTaskAction)
//            completeTaskAlert.addAction(cancelAction)
//        self.present(completeTaskAlert, animated: true)
        }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row]
        else {
            return nil
        }
    
        
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Не выполнена") {_,_,_ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        let actionSwipeToEdit = UIContextualAction(style: .normal, title: "Изменить") {_,_,_ in
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            editScreen.doAfterEdit = {[unowned self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                tasks[taskType]![indexPath.row] = editedTask
                tableView.reloadData()
            }
            self.navigationController?.pushViewController(editScreen, animated: true)
        }
        actionSwipeToEdit.backgroundColor = .darkGray
        let actionsConfiguration :UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeInstance, actionSwipeToEdit])
        }else{
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeToEdit])
        }
    return actionsConfiguration
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
        
// TODO: - реализовать здесь изменение  Entity.TaskPriority в CoreData (delete и insert)
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        
        tasks[taskTypeto]!.insert(movedTask, at: destinationIndexPath.row)
        if taskTypeFrom != taskTypeto {
            tasks[taskTypeto]![destinationIndexPath.row].type = taskTypeto
            
        }
        
        tableView.reloadData()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//MARK: - Core Data Magic
    func saveTask(withTitle: String, withType: TaskPriority, withStatus: TaskStatus){
        let context = dataStoreManager.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "TaskEntity", in: context)
        else {
            return
        }
        let taskEntity = TaskEntity(entity: entity, insertInto: context)
        let task = Task(title: withTitle, type: withType, status: withStatus)
            
       
        
        taskEntity.title = withTitle
        taskEntity.taskPriority = withType
        taskEntity.taskStatus = withStatus
        taskEntity.type = withType.rawValue
        taskEntity.status = withStatus.rawValue
        do {
            try context.save()
            tasks[withType]?.append(task)
            print("taskObject appended")
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
}

