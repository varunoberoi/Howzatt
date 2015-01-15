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

    @IBOutlet var mi: MenuItemViewController?

    var score: Score!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    var matches = NSMutableDictionary()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        statusItem.title = "No Match"
        statusItem.menu = statusMenu
        
        score = Score(onUpdateListener: displayScore)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func displayScore(score: String, matchList: NSMutableArray) -> Void {
        statusItem.title = score
        statusItem.menu = statusMenu
        println(score)
        insertMatchesIntoMenu(matchList)
    }
    
    
    func insertMatchesIntoMenu(matchList: NSMutableArray){
        statusMenu.removeAllItems()
        for (index, match) in enumerate(matchList) {
            let item = statusMenu.insertItemWithTitle(match["title"] as String, action: "selectMatch:", keyEquivalent:match["link"] as String, atIndex: index) as NSMenuItem?
            item?.tag = index
            mi = MenuItemViewController(nibName: "MenuItem", bundle: nil)
            item?.view = mi?.view
            mi?.setLabel(match["title"] as String)
        }
        var seperator = NSMenuItem.separatorItem()
        statusMenu.addItem(seperator)
        statusMenu.insertItemWithTitle("Quit", action: "quit:", keyEquivalent: "quit", atIndex: matchList.count + 1)
    }
    
    @IBAction func selectMatch(sender: NSMenuItem){
        println("Select Match", sender)
        score.selectedMatch = sender.tag
    }
    
    @IBAction func quit(sender: NSMenuItem){
        println("Exting. . .")
        NSApplication.sharedApplication().terminate(self)
    }
    
}

