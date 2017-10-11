//
//  AppDelegate.swift
//  Cricket Scoreboard
//
//  Created by Varun Oberoi on 10/01/15.
//  Copyright (c) 2015 Varun Oberoi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, XMLParserDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var searchMenuItem: NSMenuItem!
    
    var score: Score!
    
    let statusItem = NSStatusBar.system.statusItem(withLength:-1)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem.title = "Loading Matches";
        statusItem.menu = statusMenu
        
        // Passing an event handler to Score Class
        score = Score(onUpdateListener: displayScore)
        score.updateScore()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        
    }
    
    func appBundleName() -> String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
    
    // Called everytime score updates
    func displayScore(score: String, matchList: [[String: String]]) -> Void {
        statusItem.title = score
        statusItem.menu = statusMenu
        insertMatchesIntoMenu(matchList: matchList)
    }
    
    func insertMatchesIntoMenu(matchList: [[String: String]]) {
        // Clearing previous menuItems
        statusMenu.removeAllItems()
        
        // Adding new matches to the menu
        for (index, match) in matchList.enumerated() {
            let item = NSMenuItem(title: match["title"]!, action: #selector(selectMatch), keyEquivalent: "")
            var matchLink : String = match["link"]!
            matchLink = matchLink
                .trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            
            let matchLinkURL = NSURL(string: matchLink)
            item.representedObject = matchLinkURL

            //item.on
            statusMenu.insertItem(item, at: (index))
            item.state = NSControl.StateValue.off
            item.tag = index
            if score.selectedMatch == index {
                item.state = NSControl.StateValue.on
            }
        }
        
        // Other menuItems
        let seperator = NSMenuItem.separator()
        statusMenu.addItem(seperator)
        statusMenu.insertItem(withTitle: "Quit ", action: #selector(quit), keyEquivalent: "q", at: matchList.count + 1)
    }
    
    // On Click Event Handler for menuItems
    @IBAction func selectMatch(sender: NSMenuItem) {
        if NSEvent.modifierFlags == NSEvent.ModifierFlags.command {
            NSWorkspace.shared.open((sender.representedObject as! NSURL) as URL);
        }
        //Uncheck previous match
        statusMenu.item(withTag: score.selectedMatch)?.state = NSControl.StateValue.off
        
        score.selectedMatch = sender.tag
        
        // Ticking click match
        sender.state = NSControl.StateValue.on
        
        score.updateScore()
    }
    
    // Event Handler for quit menuItem 
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
}

