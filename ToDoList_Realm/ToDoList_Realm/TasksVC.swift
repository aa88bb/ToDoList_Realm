//
//  TasksVC.swift
//  ToDoList_Realm
//
//  Created by zhuchenglong on 2017/4/2.
//  Copyright © 2017年 goodcoder.zcl. All rights reserved.
//

import UIKit
import RealmSwift

class TasksVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tasksTableView: UITableView!
    
    let myRealm = try! Realm()
    var selectedList : TaskList!
    var openTasks : Results<Task>!
    var completedTasks : Results<Task>!
    var currentCreateAction:UIAlertAction!
    
    var isEditingMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedList.name
        readTasksAndUpateUI()
        
    }
    
    @IBAction func didClickOnNewTask(_ sender: UIBarButtonItem) {
        self.displayAlertToAddTask(nil)
    }
    
    @IBAction func didClickOnEditTasks(_ sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        self.tasksTableView.setEditing(isEditingMode, animated: true)
    }
    
    func readTasksAndUpateUI(){
        
        completedTasks = selectedList.tasks.filter("isCompleted = true")
        openTasks = selectedList.tasks.filter("isCompleted = false")
        
        tasksTableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource -
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0{
            return openTasks.count
        }
        return completedTasks.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0{
            return "OPEN TASKS"
        }
        return "COMPLETED TASKS"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        var task: Task!
        if indexPath.section == 0{
            task = openTasks[indexPath.row]
        }
        else{
            task = completedTasks[indexPath.row]
        }
        
        cell?.textLabel?.text = task.name
        return cell!
    }
    
    
    func displayAlertToAddTask(_ updatedTask:Task!){
        
        var title = "New Task"
        var doneTitle = "Create"
        if updatedTask != nil{
            title = "Update Task"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your task.", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let taskName = alertController.textFields?.first?.text
            
            if updatedTask != nil{
                // update mode
                try! self.myRealm.write{
                    updatedTask.name = taskName!
                    self.readTasksAndUpateUI()
                }
            }
            else{
                
                let newTask = Task()
                newTask.name = taskName!
                
                try! self.myRealm.write{
                    
                    self.selectedList.tasks.append(newTask)
                    self.readTasksAndUpateUI()
                }
            }
            
            
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task Name"
            textField.clearButtonMode = .always
            textField.addTarget(self, action: #selector(self.taskNameFieldDidChange(_:)) , for: UIControlEvents.editingChanged)
            if updatedTask != nil{
                textField.text = updatedTask.name
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Enable the create action of the alert only if textfield text is not empty
    func taskNameFieldDidChange(_ textField:UITextField){
        self.currentCreateAction.isEnabled = (textField.text?.characters.count)! > 0
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (deleteAction, indexPath)  in
            
            //Deletion will go here
            
            var taskToBeDeleted: Task!
            if indexPath.section == 0{
                taskToBeDeleted = self.openTasks[indexPath.row]
            }
            else{
                taskToBeDeleted = self.completedTasks[indexPath.row]
            }
            
            try! self.myRealm.write{
                self.myRealm.delete(taskToBeDeleted)
                self.readTasksAndUpateUI()
            }
        }
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Editing will go here
            var taskToBeUpdated: Task!
            if indexPath.section == 0{
                taskToBeUpdated = self.openTasks[indexPath.row]
            }
            else{
                taskToBeUpdated = self.completedTasks[indexPath.row]
            }
            
            self.displayAlertToAddTask(taskToBeUpdated)
            
        }
        
        let doneAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Done") { (doneAction, indexPath) -> Void in
            // Editing will go here
            var taskToBeUpdated: Task!
            if indexPath.section == 0{
                taskToBeUpdated = self.openTasks[indexPath.row]
            }
            else{
                taskToBeUpdated = self.completedTasks[indexPath.row]
            }
            try! self.myRealm.write{
                taskToBeUpdated.isCompleted = true
                self.readTasksAndUpateUI()
            }
            
        }
        return [deleteAction, editAction, doneAction]
    }

    

}
