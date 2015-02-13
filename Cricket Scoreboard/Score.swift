//
//  Score.swift
//  Cricket Scoreboard
//
//  Created by Varun Oberoi on 12/01/15.
//  Copyright (c) 2015 Varun Oberoi. All rights reserved.
//

import Foundation

class Score: NSObject, NSXMLParserDelegate {
    
    // By default first match in the list is selected
    var selectedMatch = 0
    
    // Cricinfo RSS Link
    var RSS_URL = "http://static.cricinfo.com/rss/livescores.xml"
    
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var link = NSMutableString()
    
    var url = NSURL()
    var onUpdateListener: (String, NSMutableArray) -> Void
    
    init(onUpdateListener: (String, NSMutableArray) -> Void){
        self.onUpdateListener = onUpdateListener
        super.init()
        posts = []
        url = NSURL(string: RSS_URL)!
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
        NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: "updateScore", userInfo: nil, repeats: true)
    }
    
    func updateScore(){
        println("Updating Score")
        
        posts = []
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
        
        if posts.count > selectedMatch + 1 {
            var score = posts[selectedMatch]["title"] as String
            score = score.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            self.onUpdateListener(score, posts)
        }
    }
    
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)
    {
        element = elementName
        if (elementName as NSString).isEqualToString("item")
        {
            elements = NSMutableDictionary.alloc()
            elements = [:]
            title1 = NSMutableString.alloc()
            title1 = ""
            link = NSMutableString.alloc()
            link = ""
        }
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!)
    {
        if element.isEqualToString("title") {
            title1.appendString(string)
        } else if element.isEqualToString("guid") {
            link.appendString(string)
        }
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        if (elementName as NSString).isEqualToString("item") {
            if !title1.isEqual(nil) {
                elements.setObject(title1, forKey: "title")
            }
            if !link.isEqual(nil) {
                elements.setObject(link, forKey: "link")
            }
            
            posts.addObject(elements)
        }
    }
    
}