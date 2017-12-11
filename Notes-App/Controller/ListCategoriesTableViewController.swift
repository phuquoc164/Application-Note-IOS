//
//  ListCategoriesTableViewController.swift
//  Notes-App
//
//  Created by Dinh Phu Quoc on 09/12/2017.
//  Copyright © 2017 if26. All rights reserved.
//

import UIKit
import SVProgressHUD

class ListCategoryTableViewController: UITableViewController {
    
    
    @IBOutlet var categoryTableView: UITableView!
    weak var actionToEnable : UIAlertAction?
    
    var listCategories = [Category]()
    var tableCategories = Categories()
    
    var newCategoryIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        categoryTableView.allowsSelectionDuringEditing = true
        
        tableCategories.createTable()
        retrievelistCategoriesFromDatabase()
        categoryTableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let ajustement = isEditing ? 1 : 0
        return listCategories.count + ajustement
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        if indexPath.row >= listCategories.count && isEditing {
            cell.textLabel?.text = "Add New Category"
        } else {
            cell.textLabel?.text = listCategories[indexPath.row].categoryName
        }
        
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            categoryTableView.beginUpdates()
            let indexPath = IndexPath(row: listCategories.count, section: 0)
            categoryTableView.insertRows(at: [indexPath], with: .automatic)
            categoryTableView.endUpdates()
            categoryTableView.setEditing(true, animated: true)
        } else {
            categoryTableView.beginUpdates()
            let indexPath = IndexPath(row: listCategories.count, section: 0)
            categoryTableView.deleteRows(at: [indexPath], with: .automatic)
            categoryTableView.endUpdates()
            categoryTableView.setEditing(false, animated: true)
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableCategories.deleteCategory(listCategories[indexPath.row].categoryName)
            retrievelistCategoriesFromDatabase()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            let categoryNameAdd = "New Category " + String(newCategoryIndex)
            let categoryAdd = Category(categoryName: categoryNameAdd)
            listCategories.append(categoryAdd)
            tableCategories.insertNewCategory(categoryName: categoryNameAdd)
            tableView.insertRows(at: [indexPath], with: .automatic)
            newCategoryIndex+=1
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row >= listCategories.count {
            return .insert
        } else {
            return .delete
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

        if isEditing && indexPath.row >= listCategories.count {
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isEditing {
            if indexPath.row == 0 {
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                let alert = UIAlertController(title: "Modify Category", message: nil, preferredStyle: .alert)
                
                let oldCategory = (tableView.cellForRow(at: indexPath)?.textLabel?.text)!
                alert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = oldCategory
                })
                
                let action = UIAlertAction(title: "Submit", style: .default, handler: { (_) in
                    guard
                        let newCategory = alert.textFields?.first?.text
                        else {return}
                    if newCategory != "" {
                        if self.tableCategories.checkCategoryExists(categoryName: newCategory) {
                            SVProgressHUD.setForegroundColor(UIColor.white)
                            SVProgressHUD.setBackgroundColor(UIColor.red)
                            SVProgressHUD.showError(withStatus: "This Category is already existed!")
                        } else {
                            self.tableCategories.updateCategory(oldCategory: oldCategory, newCategory: newCategory)
                            Notes().updateCategory(oldCategory: oldCategory, newCategory: newCategory)
                            self.retrievelistCategoriesFromDatabase()
                            
                            
                            self.categoryTableView.reloadData()
                        }
                    } else {
                        SVProgressHUD.showError(withStatus: "Category mustn't be empty!")
                    }
                })
                
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(action)
                alert.addAction(actionCancel)
                present(alert, animated: true, completion: nil)
            }
        }
        
        if indexPath.row >= listCategories.count && isEditing {
            self.tableView(tableView, commit: .insert, forRowAt: indexPath)
        }
    }
    
    func retrievelistCategoriesFromDatabase(){
        listCategories = tableCategories.retrieveListCategoriesFromDatabase()
    }
    
    @IBAction func actionButtonPressed(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        categoryChosen = "Home"
    }
}

