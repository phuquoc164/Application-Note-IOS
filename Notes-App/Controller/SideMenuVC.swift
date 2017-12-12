//
//  SideMenuVC.swift
//  Notes-App
//
//  Created by Dinh Phu Quoc on 05/12/2017.
//  Copyright © 2017 if26. All rights reserved.
//

import UIKit

var categoryChosen = "Home"

class SideMenuVC: UITableViewController {
    
    @IBOutlet var sideMenuTableView: UITableView!
    
    var listCategories = [Category]()
    var tableCategories = Categories()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableCategories.createTable()
        retrievelistCategoriesFromDatabase()
        sideMenuTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrievelistCategoriesFromDatabase()
        sideMenuTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else {
            return listCategories.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "List Categories"
        } else {
            return "MENU"
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMenu", for: indexPath)

        // Configure the cell...
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Add / Modify Category"
        } else {
            cell.textLabel?.text = listCategories[indexPath.row].categoryName
        }

        return cell
    }
    
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name("showSideMenu"), object: nil)
        if indexPath.section == 0 {
            NotificationCenter.default.post(name: NSNotification.Name("showModifyCategoryInterface"), object: nil)
        } else if indexPath.section == 1 {
            categoryChosen = (tableView.cellForRow(at: indexPath)?.textLabel?.text)!
            NotificationCenter.default.post(name: NSNotification.Name("showCategoryInterface"), object: nil)
        }
        
    }
   
    func retrievelistCategoriesFromDatabase(){
        listCategories = tableCategories.retrieveListCategoriesFromDatabase()
    }

}
