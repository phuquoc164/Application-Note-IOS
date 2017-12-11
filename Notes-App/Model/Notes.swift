//
//  Notes.swift
//  Notes-App
//
//  Created by Dinh Phu Quoc on 07/12/2017.
//  Copyright © 2017 if26. All rights reserved.
//

import Foundation
import UIKit
import SQLite

class Notes {
    
    var database : Connection!
    
    let tableNotes = Table("notes")
    
    let id = Expression<Int>("id")
    let titre = Expression<String>("titre")
    let content = Expression<String>("content")
    let imageBase64 = Expression<String>("imageBase64")
    let category = Expression<String>("category")
    let dateCreated = Expression<Date>("dateCreated")
    let isModified = Expression<Bool>("isModified")
    
    init(){
        // TODO: Create connection to database
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("notes").appendingPathExtension("sqlite3")
            self.database = try Connection(fileUrl.path)
            
        } catch {
            print("Error connect to database: \(error)")
        }
    }
    
    func createTable(){
        // TODO: Create database
        do {
            try database.run(tableNotes.create(ifNotExists: true) { (table) in
                table.column(id, primaryKey: true)
                table.column(titre)
                table.column(content)
                table.column(imageBase64)
                table.column(category)
                table.column(dateCreated,unique:true)
                table.column(isModified)
                table.unique(titre,content,imageBase64,category)
            })
        } catch {
            print("Error create database: \(error)")
        }
        
        
    }
    
    
    func sortNoteTableDateCreated(tableSorted : Table) -> Table{
        return tableSorted.order(self.dateCreated.desc)
    }
    
    
    func insertNewNoteToTable(titre: String, content: String,imageBase64: String, date: Date) {
        let insert = self.tableNotes.insert(self.titre <- titre, self.content <- content, self.imageBase64 <- imageBase64, self.category <- categoryChosen, self.dateCreated <- date, self.isModified <- false)
        
        do {
            try database.run(insert)
            print("New Note inserted")
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("constraint failed: \(message), in \(statement)")
        } catch let error {
            print("insertion failed: \(error)")
        }
    }
    
    
    func updateNote(titre: String, content: String,imageBase64: String, dateCreated: Date, isModified: Bool) {
        print("Mau thu \(dateCreated)")
        do {
            for note in try database.prepare(tableNotes) {
                print(note[self.dateCreated])
            }
        } catch {
            print("Error update list Notes From Table: \(error)")
        }
        let noteUpdate = self.tableNotes.filter(self.dateCreated == dateCreated)
        do {
            try database.run(noteUpdate.update(self.titre <- titre, self.content <- content,self.imageBase64 <- imageBase64, self.isModified <- isModified))
            print("Note Updated")
        } catch {
            print("Error Note Update \(error)")
        }
    }
    
    
    func deleteNote(titre: String, content: String) {
        let noteDelete = self.tableNotes.filter(self.titre == titre && self.content == content && self.category == categoryChosen)
        do {
            if try self.database.run(noteDelete.delete()) > 0 {
                print("Note deleted")
            } else {
                print("Note Not Found")
            }
        } catch {
            print("Error Delete Note : \(error)")
        }
    }
    
    func deleteNotesCategory(categoryName: String) {
        let notesDelete = self.tableNotes.filter(self.category == categoryName)
        
        do {
            try database.run(notesDelete.delete())
            print("Delete All notes dans \(categoryName)")
        } catch {
            print("Error Del all notes dans \(categoryName): \(error)")
        }
    }
    
    
    func checkNoteExists(titre: String, content: String, imageBase64: String) -> Bool? {
        var valueReturn : Bool?
        let note = self.tableNotes.filter(self.titre == titre && self.content == content && self.imageBase64 == imageBase64 && self.category == categoryChosen)
        do {
            let count = try database.scalar(note.count)
            if count > 0 {
                valueReturn = true
            } else {
                valueReturn = false
            }
        } catch {
            print("Error check Note Existe \(error)")
        }

        return valueReturn
    }
    
    
    func retrievelistNotesFromDatabase(categoryChosen: String) -> [Note] {
        var listNotes = [Note]()
        let noteTableFiltre = self.filtreNotreCategory(categoryChosen)
        do {
            for note in try database.prepare(noteTableFiltre) {
                let newNote = Note(titre: note[titre], content:  note[content], category: note[category], imageBase64: note[imageBase64], dateCreated: note[dateCreated], isModified: note[isModified])
                listNotes.append(newNote)
            }
        } catch {
            print("Error update list Notes From Table: \(error)")
        }
        
        return listNotes
    }
    
    func filtreNotreCategory(_ category: String) -> Table {
        var filtreTable = self.tableNotes.filter(self.category == category)
        filtreTable = self.sortNoteTableDateCreated(tableSorted: filtreTable)
        return filtreTable
    }
    
    func updateCategory(oldCategory: String, newCategory: String) {
        let categoryUpdate = self.tableNotes.filter(self.category == oldCategory)
        do {
            try database.run(categoryUpdate.update(self.category <- newCategory))
            print("\(oldCategory) update to \(newCategory)")
        } catch {
            print("update failed: \(error)")
        }
    }
}
