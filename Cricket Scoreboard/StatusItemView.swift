//
//  StatusItemView.swift
//  Cricket Scoreboard
//
//  Created by Varun Oberoi on 22/01/15.
//  Copyright (c) 2015 Varun Oberoi. All rights reserved.
//

import Foundation
import Cocoa

class StatusItemView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect);
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(dirtyRect: NSRect) {
        println("Draw Rect is called");
        println(dirtyRect)
        setMen
    }
    
    override func mouseDown(theEvent: NSEvent) {
        println("StatusItemView is clicked(mouseDown)");
    }
    
}