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
    let RSS_URL = "http://static.cricinfo.com/rss/livescores.xml"
    
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var link = NSMutableString()
    
    var url = NSURL()
    var onUpdateListener: (String, NSMutableArray) -> Void
    
    init(onUpdateListener: (String, NSMutableArray) -> Void) {
        self.onUpdateListener = onUpdateListener
        super.init()
        posts = []
        url = NSURL(string: RSS_URL)!
        NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: "updateScore", userInfo: nil, repeats: true)
    }
    
    func updateScore() {
        print("Updating Score")
        
        posts = []
        parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
        
        if posts.count >= selectedMatch + 1 {
            let detailed_match_url = posts[selectedMatch]["link"] as! String
            let url = NSURL(string: detailed_match_url)
            let request = NSURLRequest(URL: url!)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                let html = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                
                let parsedscore = self.parseScoreFromPage(html as String, title: self.posts[self.selectedMatch]["title"] as! String)
                
                self.onUpdateListener(parsedscore, self.posts)
            }
        }
    }
    
    func parseScoreFromPage(page:String, title:String) -> String {
        let strFrom = "<title>"
        let strTo = "</title>"
        var score = (page.componentsSeparatedByString(strFrom)[1].componentsSeparatedByString(strTo)[0])
        if score.containsString("|"){
            score = score.componentsSeparatedByString("|")[0]
        }
        if score.containsString("("){
            score = score.componentsSeparatedByString("(")[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }else{
            score = title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        return score
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName
        if (elementName as NSString).isEqualToString("item")
        {
            elements = [:]
            title1 = ""
            link = ""
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if element.isEqualToString("title") {
            title1.appendString(string)
        } else if element.isEqualToString("guid") {
            link.appendString(string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
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