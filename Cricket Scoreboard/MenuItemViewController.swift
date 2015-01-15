//
//  MenuItemViewController.swift
//  Cricket Scoreboard
//
//  Created by Varun Oberoi on 14/01/15.
//  Copyright (c) 2015 Varun Oberoi. All rights reserved.
//

import Foundation
import Cocoa

class MenuItemViewController: NSViewController {
    
    @IBOutlet weak var label: NSTextField!
    
    @IBOutlet weak var openLink: NSButton!
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    func setLabel(label: String){
        self.label.stringValue = label
        self.label.sizeToFit()
    }
    
}