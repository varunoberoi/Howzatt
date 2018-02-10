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
            guard let title = match["title"],
                let matchLink = match["link"] else { continue }

            let item = NSMenuItem(title: title,
                                  action: #selector(selectMatch), keyEquivalent: "")

            let matchLinkUrlString = matchLink
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let matchLinkUrlString = matchLinkUrlString,
                let matchLinkURL = NSURL(string: matchLinkUrlString) {
                item.representedObject = matchLinkURL
            }

            //item.on
            statusMenu.insertItem(item, at: (index))
            item.state = .off
            item.tag = index
            if score.selectedMatch == index {
                item.state = .on
            }
        }
        
        // Other menuItems
        let seperator = NSMenuItem.separator()
        statusMenu.addItem(seperator)
        statusMenu.insertItem(withTitle: "Quit", action: #selector(quit),
                              keyEquivalent: "q", at: matchList.count + 1)
    }
    
    // On Click Event Handler for menuItems
    @IBAction func selectMatch(sender: NSMenuItem) {
        if NSEvent.modifierFlags == .command,
            let url = sender.representedObject as? NSURL {
            NSWorkspace.shared.open(url as URL)
        }
        //Uncheck previous match
        statusMenu.item(withTag: score.selectedMatch)?.state = .off
        
        score.selectedMatch = sender.tag
        
        // Ticking click match
        sender.state = .on
        
        score.updateScore()
    }
    
    // Event Handler for quit menuItem 
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}

