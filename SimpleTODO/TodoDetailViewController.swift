//
//  TodoDetailViewController.swift
//  SimpleTODO
//
//  Created by gholizade on 7/10/17.
//  Copyright © 2017 saeid gholizade. All rights reserved.
//

import UIKit

class TodoDetailViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource  {
    @IBOutlet var nameText : UITextField!
    @IBOutlet var priorityText : UITextField!
    @IBOutlet var dateText : UITextField!
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var datePicker: UIDatePicker!
    
    
    let priorities = ["", "low", "mid", "high"]
    static var todoIndex : Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = .dateAndTime
        priorityText.inputView = pickerView
        dateText.inputView = datePicker
        
        nameText.text = getTodo()?.todoName
        priorityText.text = getTodo()?.todoPriority
        if getTodo()?.todoDate != nil {
            dateText.text = "\((getTodo()?.todoDate)!)"
        }
        
        
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTodo() -> TodoRow? {
        return TodoDetailViewController.todoIndex < 0 ? nil : (ViewController.shared.shouldFilterData ? ViewController.shared.filterData[TodoDetailViewController.todoIndex] : ViewController.shared.data[TodoDetailViewController.todoIndex])
    }
    
    func saveDate(){
        ViewController.shared.saveTodo()
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return priorities.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priorities[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        priorityText.text = priorities[row]
        getTodo()?.todoPriorityIndex = row
        getTodo()?.todoPriority = priorityText.text!
        saveDate()
    }

    @IBAction func nameChanged(sender: UITextField){
        getTodo()?.todoName = sender.text!
        saveDate()
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        dateText.text = "\(sender.date)"
        getTodo()?.todoDate = sender.date
        saveDate()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
