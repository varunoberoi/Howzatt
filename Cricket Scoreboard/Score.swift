//
//  Score.swift
//  Cricket Scoreboard
//
//  Created by Varun Oberoi on 12/01/15.
//  Copyright (c) 2015 Varun Oberoi. All rights reserved.
//

import Foundation

private extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

private enum ScoreElement: String {
    case title, guid
}

struct ScoreItem {
    let title: String
    let link: String
}

class Score: NSObject {
    
    enum ParsingError: Error {
        case RuntimeError(String)
    }
    
    // Map storing emoji flags for each country
    private let flags = ["aus": "🇦🇺", "ind": "🇮🇳", "sa": "🇿🇦",
                         "nz": "🇳🇿", "sl": "🇱🇰", "eng": "🏴󠁧󠁢󠁥󠁮󠁧󠁿",
                         "ban": "🇧🇩", "pak": "🇵🇰", "wi": "",
                         "ire": "🇮🇪", "zim": "🇿🇼", "afg": "🇦🇫"]

    private let liveScoresUrl =
        URL(string: "http://static.cricinfo.com/rss/livescores.xml")!
    private let matchListUpdateInterval = 25.0

    // By default first match in the list is selected
    var selectedMatch = 0

    private var allMatchScores = [ScoreItem]()
    private var currentScoreElement: ScoreElement?
    private var currentTitle = ""
    private var currentLink = ""

    typealias ScoreUpdate = (String, [ScoreItem]) -> Void
    var onUpdateListener: ScoreUpdate
    
    init(onUpdateListener: @escaping ScoreUpdate) {
        self.onUpdateListener = onUpdateListener
        super.init()

        Timer.scheduledTimer(timeInterval: matchListUpdateInterval,
                             target: self, selector: #selector(updateScore),
                             userInfo: nil, repeats: true).fire()
    }
    
    @objc func updateScore() {
        guard let xmlParser = XMLParser(contentsOf: liveScoresUrl)
            else { return }

        print("Updating Score")

        allMatchScores.removeAll();

        xmlParser.delegate = self
        xmlParser.parse()
        
        if allMatchScores.count >= selectedMatch + 1 {
            let selectedMatchDict = allMatchScores[selectedMatch]
            guard let matchUrl =
                URL(string: selectedMatchDict.link) else { return }

            URLSession.shared.dataTask(with: URLRequest(url: matchUrl))
            { [weak self] data, response, error in
                if error != nil {
                    print("Error while fetching html for match page")
                    return
                }

                guard let strongSelf = self, let data = data,
                    let html = String(data: data, encoding: .utf8)
                    else { return }

                guard let parsedscore = strongSelf.parseScoreFromPage(
                    page: html as String, title: selectedMatchDict.title)
                    else {
                        print("An error occurred while parsing score")
                        return
                }
                strongSelf.onUpdateListener(
                    parsedscore, strongSelf.allMatchScores)
            }.resume()
        }
    }
    
    func parseScoreFromPage(page: String, title: String) -> String? {
        let strFrom = "<title>"
        let strTo = "</title>"

        guard let score = page.components(separatedBy: strFrom)[safe: 1]?
            .components(separatedBy: strTo)[safe: 0] else { return nil }

        var formattedScore = ""
        if score.contains("|") {
            formattedScore = score.components(separatedBy: "|")[0]
        }

        var overs = ""
        if formattedScore.contains("(") {
            var parts = formattedScore.components(separatedBy: "(")
            
            formattedScore = parts[0]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            overs = parts[1]

            if overs.contains("ov") {
                overs = overs.components(separatedBy: "ov")[0]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                overs = ""
            }
        }
        
        if !overs.isEmpty {
            formattedScore = getFlag(score: formattedScore)
            formattedScore = "\(formattedScore) (\(overs) ov)"
        } else {
            formattedScore = title.trimmingCharacters(
                in: .whitespacesAndNewlines)
        }

        // Add space around &
        formattedScore = formattedScore.replacingOccurrences(
            of: "&", with: " & ")

        return formattedScore
    }
    
    func getFlag(score: String) -> String {
        for (country, flagunicode) in flags
            where score.lowercased().contains(country) {
            return flagunicode + score
        }
        return score
    }

    private func isScoreItem(_ elementName: String) -> Bool {
        return elementName == "item"
    }
}

extension Score: XMLParserDelegate {

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String]) {
        currentScoreElement = ScoreElement(rawValue: elementName)

        if isScoreItem(elementName) {
            currentTitle = ""
            currentLink = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let element = currentScoreElement {
            switch element {
            case .title:
                currentTitle.append(
                    string.trimmingCharacters(in: .whitespacesAndNewlines))
            case .guid:
                currentLink.append(
                    string.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        if isScoreItem(elementName) {
            if currentTitle.isEmpty || currentLink.isEmpty { return }
            allMatchScores.append(
                ScoreItem(title: currentTitle, link: currentLink))
        }
    }
}
