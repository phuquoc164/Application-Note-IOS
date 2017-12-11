//
//  Category.swift
//  Notes-App
//
//  Created by Dinh Phu Quoc on 09/12/2017.
//  Copyright © 2017 if26. All rights reserved.
//

import Foundation

class Category {
    
    var categoryName : String
    
    init(){
        categoryName = "Home"
    }
    
    init(categoryName: String) {
        self.categoryName = categoryName
    }
}
