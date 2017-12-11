//
//  Categories.swift
//  Notes-App
//
//  Created by Dinh Phu Quoc on 09/12/2017.
//  Copyright © 2017 if26. All rights reserved.
//

import Foundation
import SQLite

class Categories {
    
    
    var database : Connection!
    
    var tableCategories = Table("categories")
    var tableNotes = Notes()
    
    let id = Expression<Int>("id")
    let categoryName = Expression<String>("categoryName")
    
    init(){
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("categories").appendingPathExtension("sqlite3")
            self.database = try Connection(fileUrl.path)
        } catch {
            print("Error connect to database category \(error)")
        }
    }
    
    func createTable(){
        do {
            try database.run(tableCategories.create(ifNotExists: true){
                table in
                table.column(id, primaryKey: .autoincrement)
                table.column(categoryName, unique: true)
            })
        }  catch {
            print("Error create database Category \(error)")
        }
        if checkCategoryExists(categoryName: "Home") == false{
            self.insertNewCategory(categoryName: "Home")
        }
        
    }
    
    func insertNewCategory(categoryName: String){
        let insert = self.tableCategories.insert(self.categoryName <- categoryName)
        do {
            try database.run(insert)
            print("New Category Inserted")
        } catch {
            print("Insertion failed: \(error)")
        }
    }
    
    func updateCategory(oldCategory: String, newCategory: String) {
        let categoryUpdate = self.tableCategories.filter(self.categoryName == oldCategory)
        do {
            try database.run(categoryUpdate.update(self.categoryName <- newCategory))
            print("\(oldCategory) update to \(newCategory)")
        } catch {
            print("update failed: \(error)")
        }
    }
    
    func deleteCategory(_ category: String){
        let categoryDelete = self.tableCategories.filter(self.categoryName == category)
        
        do {
            try database.run(categoryDelete.delete())
            print("\(category) deleted")
        } catch {
            print("Delete category error: \(error)")
        }
        
        tableNotes.deleteNotesCategory(categoryName: category)
    }
    
    func checkCategoryExists(categoryName : String) -> Bool {
        var valueReturn = true
        let tableCategoriesFilter = tableCategories.filter(self.categoryName == categoryName)
        do {
            let count = try database.scalar(tableCategoriesFilter.select(self.categoryName.distinct.count))
            print(count)
            if count > 0 {
                valueReturn = true
            } else {
                valueReturn = false
            }
        } catch {
            print("Error Check Category Exists \(error)")
        }
        
        return valueReturn
    }
    
    func retrieveListCategoriesFromDatabase() -> [Category] {
        var listCategories = [Category]()
        do {
            for category in try database.prepare(tableCategories) {
                listCategories.append(Category(categoryName: category[categoryName]))
            }
        } catch {
            print("etrieveListCategoriesFromDatabase error : \(error)")
        }
        return listCategories
    }
}

