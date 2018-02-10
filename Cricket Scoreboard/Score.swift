//
//  Score.swift
//  Cricket Scoreboard
//
//  Created by Varun Oberoi on 12/01/15.
//  Copyright (c) 2015 Varun Oberoi. All rights reserved.
//

import Foundation

class Score: NSObject, XMLParserDelegate {
    
    // Map storing emoji flags for each country
    let flags = ["aus": "\u{1F1E6}\u{1F1FA}", "ind": "\u{1F1EE}\u{1F1F3}", "sa": "\u{1F1FF}\u{1F1E6}", "nz": "\u{1F1F3}\u{1F1FF}", "sl":"\u{1F1F1}\u{1F1F0}", "eng": "\u{1F1EC}\u{1F1E7}", "ban": "\u{1F1E7}\u{1F1E9}", "pak":"\u{1F1F5}\u{1F1F0}", "wi":"", "ire": "\u{1F1EE}\u{1F1EA}", "zim": "\u{1F1FF}\u{1F1FC}", "afg": "\u{1F1E6}\u{1F1EB}"]
    
    // By default first match in the list is selected
    var selectedMatch = 0
    let matchListUpdateInterval = 25.0
    
    // Cricinfo RSS Link
//    let RSS_URL = "http://static.cricinfo.com/rss/livescores.xml"
    
    var parser = XMLParser()
    var posts = [[String: String]]()
    var elements = [String: String]()
    var element = NSString()
    var title1 = NSMutableString()
    var link = NSMutableString()
    
    var url = URL(string: "http://static.cricinfo.com/rss/livescores.xml")
    var onUpdateListener: (String, [[String: String]]) -> Void
    
    init(onUpdateListener: @escaping (String, [[String: String]]) -> Void) {
        self.onUpdateListener = onUpdateListener
        super.init()
        posts = []

//        url = NSURL(string: RSS_URL)!
        Timer.scheduledTimer(timeInterval: matchListUpdateInterval,
                             target: self, selector: #selector(updateScore),
                             userInfo: nil, repeats: true)
    }
    
    @objc func updateScore() {
        guard let url = url,
            let xmlParser = XMLParser(contentsOf: url) else { return }

        print("Updating Score")

        posts.removeAll();

        parser = xmlParser
        parser.delegate = self
        parser.parse()
        
        if posts.count >= selectedMatch + 1 {
            let tmp = posts[selectedMatch]

            guard let detailed_match_url = tmp["link"],
                let detailedMatchUrl = URL(string: detailed_match_url),
                let title = tmp["title"]
                else { return }

            let request = NSURLRequest(url: detailedMatchUrl)
            URLSession.shared.dataTask(with: request as URLRequest)
            { data, response, error in
                if (error != nil) {
                    print("Error while fetching html for match page")
                    return
                }

                guard let data = data,
                    let html = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    else { return }

                do {
                    let parsedscore = try self.parseScoreFromPage(
                        page: html as String, title: title)
                    self.onUpdateListener(parsedscore, self.posts)
                }catch {
                    print("An error occurred while parsing score")
                }
            }.resume()
        }
    }
    
    func parseScoreFromPage(page:String, title:String) throws -> String {
        let strFrom = "<title>"
        let strTo = "</title>"
        
        var score = (page.components(separatedBy: strFrom)[1]
            .components(separatedBy: strTo)[0])
        var overs = "";
        
        if score.contains("|"){
            score = score.components(separatedBy: "|")[0]
        }
        
        if score.contains("("){
            var parts = score.components(separatedBy: "(");
            
            score = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)

            overs = parts[1];
            if(overs.contains("ov")){
                overs = overs.components(separatedBy: "ov")[0].trimmingCharacters(in: .whitespacesAndNewlines)
            }else{
                overs = ""
            }
        }
        
        if !overs.isEmpty {
            score = getFlag(score: score)
            score = score + " (" + overs+" ov)";
        } else {
            score = title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return score
    }
    
    func getFlag( score: String) -> String {
        var score = score
        for (country, flagunicode) in flags {
            if score.lowercased().contains(country){
                score = flagunicode + score
            }
        }
        return score
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName as NSString
        if elementName == "item" {
            elements = [:]
            title1 = ""
            link = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if element == "title" {
            title1.append(string)
        } else if element == "guid" {
            link.append(string.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if !title1.isEqual(nil) {
                elements["title"] = title1 as String
            }
            if !link.isEqual(nil) {
                elements["link"] =  link as String
            }
            posts.append(elements)
        }
    }
    
}
