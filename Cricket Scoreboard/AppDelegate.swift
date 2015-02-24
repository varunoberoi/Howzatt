//
//  AppDelegate.swift
//  Cricket Scoreboard
//
//  Created by Varun Oberoi on 10/01/15.
//  Copyright (c) 2015 Varun Oberoi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSXMLParserDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var statusMenu: NSMenu!

    var score: Score!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    //var tick: NSImage = NSImage(named: "icon")!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem.title = "Loading Matches";
        statusItem.menu = statusMenu
        
        // Passing an event handler to Score Class
        score = Score(onUpdateListener: displayScore)
        score.updateScore()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
     
    }
    
    // Called Every 10 Seconds
    func displayScore(score: String, matchList: NSMutableArray) -> Void {
        statusItem.title = score
        statusItem.menu = statusMenu
        insertMatchesIntoMenu(matchList)
    }
    
    func insertMatchesIntoMenu(matchList: NSMutableArray){
        // Clearing previous menuItems
        statusMenu.removeAllItems()
        
        // Adding new matches to the menu
        for (index, match) in enumerate(matchList) {
            var item = NSMenuItem(title: match["title"] as String, action: "selectMatch:", keyEquivalent: match["link"] as String)
            //item.on
            statusMenu.insertItem(item, atIndex: index)
            item.state = NSOffState
            item.tag = index
            if score.selectedMatch == index {
                item.state = NSOnState
            }
        }
        
        // Other menuItems
        var seperator = NSMenuItem.separatorItem()
        statusMenu.addItem(seperator)
        statusMenu.insertItemWithTitle("Quit", action: "quit:", keyEquivalent: "quit", atIndex: matchList.count + 1)
    }
    
    // On Click Event Handler for menuItems
    @IBAction func selectMatch(sender: NSMenuItem){
        //Uncheck previous match
        statusMenu.itemWithTag(score.selectedMatch)?.state = NSOffState
        
        score.selectedMatch = sender.tag
        
        // Ticking click match
        sender.state = NSOnState
        
        score.updateScore()

    }
    
    // Event Handler for quit menuItem 
    @IBAction func quit(sender: NSMenuItem){
        NSApplication.sharedApplication().terminate(self)
    }
    
}

