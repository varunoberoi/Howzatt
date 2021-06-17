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
    
    private let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    private var scoreRepository: ScoreRepositoryType = ScoreRepository()
    private let matchListUpdateInterval = 25.0

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem.title = "Loading Matches"
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
        scoreRepository.getScores { result in
            switch result {
            case let .success(score):
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.statusItem.title = score.0
                    strongSelf.statusItem.menu = strongSelf.statusMenu
                    strongSelf.insertMatchesIntoMenu(matchList: score.1)
                }
            case let .failure(error):
                print("GetAndUpdateScores Error: \(error.localizedDescription)")
            }
        }
    }

    func insertMatchesIntoMenu(matchList: [ScoreItem]) {
        statusMenu.removeAllItems()

        for (index, match) in matchList.enumerated() {
            guard let matchLinkUrlString = match.link
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let matchLinkURL = URL(string: matchLinkUrlString) else {
                return
            }

            let item = NSMenuItem(title: match.title, action: #selector(selectMatch), keyEquivalent: "")
            item.state = scoreRepository.selectedMatch == index ? .on : .off
            item.tag = index
            item.representedObject = matchLinkURL
            statusMenu.insertItem(item, at: index)
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
        if NSEvent.modifierFlags == .command,
            let url = sender.representedObject as? URL {
            NSWorkspace.shared.open(url)
        }

        statusMenu.item(withTag: scoreRepository.selectedMatch)?.state = .off
        sender.state = .on
        scoreRepository.selectedMatch = sender.tag

        getAndUpdateScores()
    }
    
    @IBAction func quit(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
