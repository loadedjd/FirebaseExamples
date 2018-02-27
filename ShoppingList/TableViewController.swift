//
//  TableViewController.swift
//  ShoppingList
//
//  Created by Jared Williams on 1/30/18.
//  Copyright © 2018 Jared Williams. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    private var items = [String : String]()
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.addButtonPressed))
        button.tintColor = UIColor.red
        
        return  button
    }()
    
    private lazy var alertView: UIAlertController = {
        
        let alertView = UIAlertController(title: "New Grocery Item", message: "Please enter the item that you would like to add to your list", preferredStyle: .alert)
        
        alertView.addTextField { (textField: UITextField) in
            textField.placeholder = "Grocery Item"
        }
        
        let addAction = UIAlertAction(title: "Add Item", style: .default) { (action: UIAlertAction) in
            self.saveButtonPressed()
            print("Saved")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action: UIAlertAction) in
            self.dismiss(animated: true)
            print("Canceled")
        }
        
        
        alertView.addAction(cancelAction)
        alertView.addAction(addAction)
        
        
        return alertView
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseManager.sharedInstance.getAllItems()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BigCell")
        
        self.navigationItem.rightBarButtonItem = self.addButton
        self.navigationController?.navigationBar.topItem?.title = "My Grocery List"
        
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        
        
    }
    
    @objc func addButtonPressed() {
        self.present(self.alertView, animated: true, completion: nil)
    }
    
    func saveButtonPressed() {
        
        FirebaseManager.sharedInstance.pushDictionaryToRemote(data: ["Item":self.alertView.textFields![0].text!], child: "/items", autoId: true)
        FirebaseManager.sharedInstance.getAllItems()
        
        self.alertView.textFields![0].text = ""
        self.tableView.reloadData()
    }
    
    func printSomething(sting: String) {
        print(sting)
    }
    
    @objc func reloadData() {
        self.items = FirebaseManager.sharedInstance.mostRecentItems
        self.tableView.reloadData()
    }
    
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let keys = Array(self.items.keys)
        
        cell.textLabel?.text = self.items[keys[indexPath.row]]

        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

   
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let keys = Array(self.items.keys)
            self.items.removeValue(forKey: keys[indexPath.row])
            
            FirebaseManager.sharedInstance.deleteChild(path: "items/\(keys[indexPath.row])")
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let keys = Array(self.items.keys)
        
        let alert = UIAlertController(title: self.items[keys[indexPath.row]] , message: "The database ID for this item is \(keys[indexPath.row])", preferredStyle: .actionSheet)
        
        let thanksButton = UIAlertAction(title: "Got It!", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        
        
        alert.addAction(thanksButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
