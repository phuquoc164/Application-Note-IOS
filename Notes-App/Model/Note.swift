//
//  Note.swift
//  Notes-App
//
//  Created by Dinh Phu Quoc on 08/12/2017.
//  Copyright © 2017 if26. All rights reserved.
//

import Foundation
import UIKit

class Note{
    
    var titre : String
    var content : String
    var imageBase64 : String
    var category : String
    var dateCreated : Date
    var isModified : Bool
    
    init() {
        titre = "New Note"
        content = "No Additonal Text"
        category = "Home"
        dateCreated = Date()
        isModified = false
        imageBase64 = "defaultPhoto"
    }
    
    init(titre : String, content : String, category: String, imageBase64: String, dateCreated :  Date, isModified:Bool) {
        self.titre = titre
        self.content = content
        self.imageBase64 = imageBase64
        self.category = category
        self.dateCreated = dateCreated
        self.isModified = isModified
    }
}
