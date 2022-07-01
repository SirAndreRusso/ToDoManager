//
//  TaskEditController.swift
//  ToDoManager
//
//  Created by Андрей Русин on 20.06.2022.
//

import UIKit

class TaskEditController: UITableViewController {
    @IBOutlet weak var taskTitle: UITextField!
    
    @IBOutlet weak var taskTypeLabel: UILabel!
    
    @IBOutlet weak var taskStatusSwitch: UISwitch!
    private var taskTitles: [TaskPriority:String] = [.important: "Важная", .normal:"Текущая"]
    var taskText: String = ""
    var taskType: TaskPriority = .normal
    var taskStatus: TaskStatus = .planned
    var doAfterEdit: ((String, TaskPriority, TaskStatus)-> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitle?.text = taskText
        taskTypeLabel?.text = taskTitles[taskType]
    }
    override func viewWillAppear(_ animated: Bool) {
        if taskStatus == .completed {
            taskStatusSwitch.isOn = true
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskTypeScreen" {
            let destination = segue.destination as! TaskTypeController
            destination.selectedType = taskType
            destination.doAfterTypeSelected = {[unowned self] selectedType in
                taskType = selectedType
                taskTypeLabel.text = taskTitles[taskType]
            }
        }
    }
    @IBAction func saveTaskButton(_ sender: UIBarButtonItem) {
        let title = taskTitle?.text ?? ""
        let type = taskType
        let status: TaskStatus = taskStatusSwitch.isOn ? .completed: .planned
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let taskListVC = storyboard.instantiateViewController(withIdentifier: "TaskListController") as! TaskListController
        taskListVC.loadTasks()
        taskListVC.saveTask(withTitle: title, withType: type, withStatus: status)
        
        
        doAfterEdit?(title,type,status)
        
        navigationController?.popViewController(animated: true)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 3
    }
    
    
    
}
   
