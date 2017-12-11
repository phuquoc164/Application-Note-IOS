//
//  ListeNoteDansCategorieVC.swift
//  Notes-App
//
//  Created by Dinh Phu Quoc on 05/12/2017.
//  Copyright © 2017 if26. All rights reserved.
//

import UIKit
import os.log
import SQLite
import SVProgressHUD

class ListeNoteDansCategorieVC: UITableViewController{
    
    
    var tableNotes = Notes()
    var listNotes = [Note]()
    var tableCategories = Categories()
    var listCategories = [Category]()
    
    @IBOutlet var listeNotesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showCategoryInterface),
                                               name: NSNotification.Name("showCategoryInterface"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showModifyCategoryInterface),
                                               name: NSNotification.Name("showModifyCategoryInterface"),
                                               object: nil)
        
        // Style Table View
        self.listeNotesTableView.backgroundColor = UIColor(named: "#f2f2f2")
        
        navigationItem.title = categoryChosen
        
        // Create Table Notes
        tableNotes.createTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationItem.title = categoryChosen
        retrievelistNotesFromDatabase()
        listeNotesTableView.reloadData()
    }
    
    @objc func showModifyCategoryInterface(){
        performSegue(withIdentifier: "showModifyCategoryInterfaceSegue", sender: self)
    }
    
    @objc func showCategoryInterface(){
        navigationItem.title = categoryChosen
        retrievelistNotesFromDatabase()
        listeNotesTableView.reloadData()
    }
    
   
    
    // MARK: - Table view data source

    // TODO: func numberOfSection -> define the number of section in the table
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // TODO: func numberOfRowsInSection -> define the number of row in one section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listNotes.count
    }
    
    // TODO: cellForRowAt indexpath -> define the cell for
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellNote", for: indexPath)

        cell.textLabel?.text = listNotes[indexPath.row].titre
        cell.detailTextLabel?.text = listNotes[indexPath.row].content

        return cell
    }
    
    
    // TODO: canEditRow -> allow modification of cell
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let titreNoteDeleted = tableView.cellForRow(at: indexPath)?.textLabel?.text
            let contentNoteDeleted = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text
            listNotes.remove(at: indexPath.row)
            listeNotesTableView.deleteRows(at: [indexPath], with: .fade)
            tableNotes.deleteNote(titre: titreNoteDeleted!, content: contentNoteDeleted!)
        }
        
        
    }
    

    // MARK: Add Note, Modify Note
    
    
        // Todo: Ananlyse when the menu hamburger is pressed
    @IBAction func menuHamburgerPressed(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name("showSideMenu"), object: nil)
        
        if sideMenuOpen {
            listeNotesTableView.isUserInteractionEnabled = false
        } else {
            listeNotesTableView.isUserInteractionEnabled = true
        }
    }
    
    
    @IBAction func unwindToNoteList(sender: UIStoryboardSegue){
        if let source = sender.source as? NoteDetailController {
            
            if listeNotesTableView.indexPathForSelectedRow != nil {
                // Update an existing note
                let note = source.note!
                if (tableNotes.checkNoteExists(titre: note.titre, content: note.content, imageBase64: note.imageBase64))! {
                    SVProgressHUD.setForegroundColor(UIColor.white)
                    SVProgressHUD.setBackgroundColor(UIColor.red)
                    SVProgressHUD.showError(withStatus: "Your note is already existe")
                } else {
                    tableNotes.updateNote(titre: note.titre, content: note.content, imageBase64: note.imageBase64, dateCreated: note.dateCreated, isModified: true)
                    retrievelistNotesFromDatabase()
                    listeNotesTableView.reloadData()
                }
            } else {
                let newNote = source.note!
                if tableNotes.checkNoteExists(titre: newNote.titre, content: newNote.content, imageBase64: newNote.imageBase64)! {
                    SVProgressHUD.setForegroundColor(UIColor.white)
                    SVProgressHUD.setBackgroundColor(UIColor.red)
                    SVProgressHUD.showError(withStatus: "Your note is already existe")
                } else {
                    print(newNote.titre)
                    print(newNote.content)
                    tableNotes.insertNewNoteToTable(titre: newNote.titre, content: newNote.content, imageBase64: newNote.imageBase64, date: newNote.dateCreated)
                    retrievelistNotesFromDatabase()
                    self.listeNotesTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func addNotePressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addNote", sender: self)

    }
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "addNote":
            print("Add a new Note")
        case "showNoteDetail":
            guard
                let destination = segue.destination as? NoteDetailController
                else{fatalError("Unexpected destination: \(segue.destination)")}
            
            guard
                let selecteNoteCell = sender as? NoteTableViewCell
                else{ fatalError("Unexpected sender: \(String(describing: sender))")}

            guard
                let indexPath = listeNotesTableView.indexPath(for: selecteNoteCell)
                else{ fatalError("Unexpected sender: \(String(describing: sender))")}
            
            
            destination.note = listNotes[indexPath.row]
        case "showModifyCategoryInterfaceSegue":
            print("show Category")
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
    func retrievelistNotesFromDatabase(){
        listNotes = tableNotes.retrievelistNotesFromDatabase(categoryChosen: categoryChosen)
    }
    
}
