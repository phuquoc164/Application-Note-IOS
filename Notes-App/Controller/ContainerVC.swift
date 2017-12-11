//
//  ViewController.swift
//  Notes-App
//
//  Created by Dinh Phu Quoc on 05/12/2017.
//  Copyright © 2017 if26. All rights reserved.
//

import UIKit

var sideMenuOpen = false

class ContainerVC: UIViewController {
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSideMenu),
                                               name: NSNotification.Name("showSideMenu"),
                                               object: nil)
    }

    @objc func showSideMenu(){
        if sideMenuOpen {
            sideMenuConstraint.constant = -240
            sideMenuOpen = false
        } else {
            sideMenuConstraint.constant = 0
            sideMenuOpen = true
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

