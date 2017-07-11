//
//  ViewController.swift
//  SimpleTODO
//
//  Created by saeid gholizade on 7/9/17.
//  Copyright © 2017 saeid gholizade. All rights reserved.
//

import UIKit
//import RealmSwift
    
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    static var shared: ViewController!
    @IBOutlet var tableView : UITableView!
    var data : [TodoRow] = []
    var filterData : [TodoRow] = []
    
    var shouldFilterData = false
    let ident = "todo"
    let identAdd = "todoAdd"
    var tempLabel = ""
    var searchVC : UISearchController!
    var canSearch = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController.shared = self
        let searchUI = UISearchBar()
        searchUI.frame = CGRect(x: 0, y: 65, width: view.frame.width, height: 0)
        searchUI.delegate = self
        tableView.tableHeaderView = searchUI
        loadTodo()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        saveTodo()
        reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldFilterData = false
        searchBar.showsCancelButton = false
        reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        shouldFilterData = true
        filterData(filter: searchBar.text!)
        searchBar.resignFirstResponder()
        reloadData()
    }
    
    
    func filterData(filter: String){
        if filter.isEmpty {
            reloadData()
            return
        }
        filterData = data.filter({(todo) in
            let s = todo.todoName.lowercased()
            let b = s.contains(filter.lowercased())
            return b
        })
        reloadData()
    }
    
    
    @IBAction func toggleSearch(){
        UIView.animate(withDuration: 0.25, animations: { 
            self.canSearch = !self.canSearch
            var frame = self.tableView.tableHeaderView!.frame
            frame.size.height = self.canSearch ? 45 : 0
            self.tableView.tableHeaderView?.frame = frame
        }) { (error) in
            self.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return shouldFilterData ? filterData.count : data.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldFilterData {
            if filterData.count <= 0{
                return UITableViewCell()
            }
            if let cell = tableView.dequeueReusableCell(withIdentifier: ident, for: indexPath) as? TodoCell{
                cell.todoText.tag = indexPath.row
                cell.todoCheck.tag = indexPath.row
                cell.todoInfo.tag = indexPath.row
                cell.todoText.text = filterData[indexPath.row].todoName
                cell.todoCheck.isOn = filterData[indexPath.row].todoDone
                return cell
            }
        }else {
            if indexPath.row >= data.count{
                if let cell = tableView.dequeueReusableCell(withIdentifier: identAdd, for: indexPath) as? TodoCell{
                    cell.todoMake.tag = indexPath.row
                    cell.todoText.tag = indexPath.row
                    cell.todoText.text = ""
                    return cell
                }
            }else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: ident, for: indexPath) as? TodoCell{
                    cell.todoText.tag = indexPath.row
                    cell.todoCheck.tag = indexPath.row
                    cell.todoInfo.tag = indexPath.row
                    cell.todoText.text = data[indexPath.row].todoName
                    cell.todoCheck.isOn = data[indexPath.row].todoDone
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
    @IBAction func sortData(){
        let alert = UIAlertController(title: "sort by", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "reverse", style: .default, handler: { (action) in
            if self.shouldFilterData {
                self.filterData = self.filterData.reversed()
            }else {
                self.data = self.data.reversed()
            }
            self.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "name", style: .default, handler: { (action) in
            if self.shouldFilterData {
                self.filterData = self.filterData.sorted(by: { (a, b) -> Bool in
                    return a.todoName < b.todoName
                })
            }
            else {
                self.data = self.data.sorted(by: { (a, b) -> Bool in
                    return a.todoName < b.todoName
                })
            }
            self.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "priority", style: .default, handler: { (action) in
            if self.shouldFilterData {
                self.filterData = self.filterData.sorted(by: { (a, b) -> Bool in
                    return a.todoPriorityIndex < b.todoPriorityIndex
                })
            }
            else {
                self.data = self.data.sorted(by: { (a, b) -> Bool in
                    return a.todoPriorityIndex < b.todoPriorityIndex
                })
            }
            self.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "date", style: .default, handler: { (action) in
            if self.shouldFilterData {
                self.filterData = self.filterData.sorted(by: { (a, b) -> Bool in
                    guard let d0 = a.todoDate, let d1 = b.todoDate else { return true }
                    return d0 < d1
                })
            }
            else {
                self.data = self.data.sorted(by: { (a, b) -> Bool in
                    guard let d0 = a.todoDate, let d1 = b.todoDate else { return true }
                    return d0 < d1
                })
            }
            self.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "done", style: .default, handler: { (action) in
            if self.shouldFilterData {
                self.filterData = self.filterData.sorted(by: { (a, b) -> Bool in
                    return a.todoDone && !b.todoDone
                })
            }
            else {
                self.data = self.data.sorted(by: { (a, b) -> Bool in
                    return a.todoDone && !b.todoDone
                })
            }
            self.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editTodo(sender: UIButton){
        let alert = UIAlertController(title: "todo info", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "edit", style: .default, handler: { (action) in
            DispatchQueue.main.async {
                TodoDetailViewController.todoIndex = sender.tag
                self.performSegue(withIdentifier: "detail", sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "remove", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.removeTodo(sender: sender)
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func removeTodo(sender: UIButton){
        let alert = UIAlertController(title: "confirm", message: "are you sure ?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "yes", style: .default, handler: { (action) in
            self.data.remove(at: sender.tag)
            self.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "no", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @IBAction func addTodo(sender: UIButton){
        data.append(TodoRow(name: tempLabel))
        tempLabel = ""
        reloadData()
    }
    
    @IBAction func todoChanged(sender: UITextField){
        if sender.tag >= data.count {
            tempLabel = sender.text!
        }else {
            data[sender.tag].todoName = sender.text!
        }
        reloadData()
    }
    @IBAction func todoCheckChanged(sender: UISwitch){
        data[sender.tag].todoDone = sender.isOn
        reloadData()
    }
    
    func reloadData(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        saveTodo()
    }
    
    func saveTodo(){
        let sdata = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(sdata, forKey: "data")
        UserDefaults.standard.synchronize()
    }
    
    func loadTodo(){
        if let lData = UserDefaults.standard.object(forKey: "data") as? Data{
            if let loadData = NSKeyedUnarchiver.unarchiveObject(with: lData) as? [TodoRow] {
                data = loadData
            }
        }
    }

}

class TodoCell: UITableViewCell {
    @IBOutlet var todoText: UITextField!
    @IBOutlet var todoCheck : UISwitch!
    @IBOutlet var todoMake : UIButton!
    @IBOutlet var todoInfo : UIButton!
}
class TodoRow: NSObject, NSCoding {
    var todoName: String = ""
    var todoDone: Bool = false
    var todoPriority = ""
    var todoPriorityIndex : Int = 0
    var todoDate: Date?
    
    init(name: String) {
        todoName = name
    }
    init (name: String, done: Bool, priority: String, date: Date?, priorityIndex: Int){
        self.todoDone = done
        self.todoName = name
        self.todoPriority = priority
        self.todoPriorityIndex = priorityIndex
        self.todoDate = date
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        let name = aDecoder.decodeObject(forKey: "todoName") as! String
        let done = aDecoder.decodeBool(forKey: "todoDone")
        let priority = aDecoder.decodeObject(forKey: "todoPriority") as! String
        let priorityIndex = aDecoder.decodeInteger(forKey: "todoPriorityIndex")
        let date = aDecoder.decodeObject(forKey: "todoDate") as? Date
        
        self.init(name: name, done: done, priority: priority, date: date, priorityIndex: priorityIndex)
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.todoName, forKey: "todoName")
        aCoder.encode(self.todoDone, forKey: "todoDone")
        aCoder.encode(self.todoPriority, forKey: "todoPriority")
        aCoder.encode(self.todoPriorityIndex, forKey: "todoPriorityIndex")
        aCoder.encode(self.todoDate, forKey: "todoDate")
    }
}
