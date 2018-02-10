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
    
    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    var score: Score!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem.title = "Loading Matches"
        statusItem.menu = statusMenu
        
        // Passing an event handler to Score Class
        score = Score(onUpdateListener: displayScore)
    }
    
    // Called everytime score updates
    func displayScore(score: String, matchList: [ScoreItem]) -> Void {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.statusItem.title = score
            strongSelf.statusItem.menu = strongSelf.statusMenu
            strongSelf.insertMatchesIntoMenu(matchList: matchList)
        }
    }
    
    func insertMatchesIntoMenu(matchList: [ScoreItem]) {
        // Clearing previous menuItems
        statusMenu.removeAllItems()
        
        // Adding new matches to the menu
        for (index, match) in matchList.enumerated() {
            let item = NSMenuItem(title: match.title,
                                  action: #selector(selectMatch), keyEquivalent: "")

            guard let matchLinkUrlString = match.link
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let matchLinkURL = URL(string: matchLinkUrlString) else {
                    return
            }

            item.state = score.selectedMatch == index ? .on : .off
            item.tag = index
            item.representedObject = matchLinkURL

            statusMenu.insertItem(item, at: (index))
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
            let url = sender.representedObject as? URL {
            NSWorkspace.shared.open(url)
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
