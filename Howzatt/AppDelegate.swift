//
//  AppDelegate.swift
//  Cricket Scoreboard
//
//  Created by Varun Oberoi on 10/01/15.
//  Copyright (c) 2021 Varun Oberoi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, XMLParserDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var searchMenuItem: NSMenuItem!
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    private let scoreAPI = ScoreAPI()
    private var currentMatch: Match! = nil
    private var currentMatchIndex: Int = 0
    private let matchListUpdateInterval = 25.0

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem.button?.title = "Loading Matches"
        statusItem.menu = statusMenu

        Timer.scheduledTimer(
            timeInterval: matchListUpdateInterval,
            target: self,
            selector: #selector(getAndUpdateScores),
            userInfo: nil,
            repeats: true
        ).fire()
    }

    @objc func getAndUpdateScores() {
        scoreAPI.fetchScore(currentMatch: currentMatch) { result in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                if !(result.matches.count == 0) {
                    strongSelf.currentMatch = result.currentMatch
                    strongSelf.updateCurrentScore()
                    strongSelf.insertMatchesIntoMenu(matchList: result.matches)
                }
            }
            return
        }
    }
    
    func updateCurrentScore() {
        statusItem.button?.title = currentMatch.shortScore
        statusItem.button?.toolTip = currentMatch.summary
        statusItem.menu = statusMenu
    }

    func insertMatchesIntoMenu(matchList: [Match]) {
        statusMenu.removeAllItems()
        var firstItem: NSMenuItem!
        var foundMatch: Bool = false
        for (index, match) in matchList.enumerated() {
            let item = NSMenuItem(title: match.title, action: #selector(selectMatch), keyEquivalent: "")
            if index == 0 {
                firstItem = item
            }
            item.state = .off
            if currentMatch != nil && currentMatch.link == match.link {
                item.state = .on
                foundMatch = true
                currentMatchIndex = index
            }
            item.tag = index
            item.representedObject = match
            statusMenu.insertItem(item, at: index)
        }
        if !foundMatch && firstItem != nil {
            firstItem.state = .on
            currentMatchIndex = 0
        }
        
        statusMenu.addItem(.separator())

        statusMenu.insertItem(
            withTitle: "Quit",
            action: #selector(quit),
            keyEquivalent: "q",
            at: matchList.count + 1
        )
    }
    
    @IBAction func selectMatch(sender: NSMenuItem) {
        let match = sender.representedObject as? Match
        if NSEvent.modifierFlags == .command {
            if match != nil {
                guard let matchLinkUrlString = match?.link
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                    let matchLinkURL = URL(string: matchLinkUrlString) else {
                    return
                }
                NSWorkspace.shared.open(matchLinkURL)
            }
        }

        statusMenu.item(withTag: currentMatchIndex)?.state = .off
        sender.state = .on
        currentMatch = match
        updateCurrentScore()
        getAndUpdateScores()
    }
    
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
