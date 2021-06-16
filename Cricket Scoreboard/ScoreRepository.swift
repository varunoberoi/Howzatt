//
//  ScoreRepository.swift
//  Cricket Scoreboard
//
//  Created by Inder Dhir on 6/16/21.
//  Copyright © 2021 Varun Oberoi. All rights reserved.
//

import Foundation

typealias ScoreUpdate = (String, [ScoreItem])

protocol ScoreRepositoryType {
    var selectedMatch: Int { get set }
    func getScores(completion: @escaping (Result<ScoreUpdate, ScoreError>) -> Void)
}

final class ScoreRepository: NSObject, ScoreRepositoryType {

    // By default first match in the list is selected
    var selectedMatch = 0

    private let liveScoresUrl = URL(string: "http://static.cricinfo.com/rss/livescores.xml")!
    private var allMatchScores = [ScoreItem]()
    private var currentScoreElement: ScoreElement?
    private var currentTitle = ""
    private var currentLink = ""

    func getScores(completion: @escaping (Result<ScoreUpdate, ScoreError>) -> Void) {
        guard let xmlParser = XMLParser(contentsOf: liveScoresUrl) else {
            completion(.failure(.xmlParserError))
            return
        }

        allMatchScores.removeAll()

        xmlParser.delegate = self
        xmlParser.parse()

        guard selectedMatch + 1 <= allMatchScores.count else {
            completion(.failure(.other))
            return
        }

        let selectedMatchDict = allMatchScores[selectedMatch]
        guard let matchUrl = URL(string: selectedMatchDict.link) else {
            completion(Result.failure(.badMatchUrl))
            return
        }

        URLSession.shared.dataTask(with: URLRequest(url: matchUrl))
        { [weak self] data, response, error in
            if let error = error {
                print("Error while fetching html for match page: \(error.localizedDescription)")
                completion(.failure(.networkError))
                return
            }

            guard let strongSelf = self,
                    let data = data,
                    let html = String(data: data, encoding: .utf8) else {
                completion(.failure(.networkError))
                return
            }

            guard let parsedScore = strongSelf.parseScoreFromPage(
                page: html as String, title: selectedMatchDict.title
            ) else {
                print("An error occurred while parsing score")
                completion(.failure(.networkError))
                return
            }

            completion(.success((parsedScore, strongSelf.allMatchScores)))
        }.resume()
    }

    private func isScoreItem(_ elementName: String) -> Bool { elementName == "item" }

    private func parseScoreFromPage(page: String, title: String) -> String? {
        let strFrom = "<title>"
        let strTo = "</title>"

        guard let score = page.components(separatedBy: strFrom)[safe: 1]?
                .components(separatedBy: strTo)[safe: 0] else { return nil }

        var formattedScore = score.contains("|") ? score.components(separatedBy: "|")[0] : ""

        var overs = ""
        if formattedScore.contains("(") {
            let parts = formattedScore.components(separatedBy: "(")
            formattedScore = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            overs = parts[1]

            overs = overs.contains("ov") ?
                overs.components(separatedBy: "ov")[0].trimmingCharacters(in: .whitespacesAndNewlines) :
                ""
        }

        formattedScore = (
            overs.isEmpty ?
            title.trimmingCharacters(in: .whitespacesAndNewlines) :
            "\(getFlag(score: formattedScore)) (\(overs) ov)"
        ).replacingOccurrences(of: "&", with: " & ")

        return formattedScore
    }

    private func getFlag(score: String) -> String {
        for (country, flagunicode) in flags where score.lowercased().contains(country) {
            return flagunicode + score
        }
        return score
    }
}

extension ScoreRepository: XMLParserDelegate {

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String]
    ) {
        currentScoreElement = ScoreElement(rawValue: elementName)
        guard isScoreItem(elementName) else { return }
        currentTitle = ""
        currentLink = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentScoreElement {
        case .title:
            currentTitle.append(string.trimmingCharacters(in: .whitespacesAndNewlines))
        case .guid:
            currentLink.append(string.trimmingCharacters(in: .whitespacesAndNewlines))
        default:
            break
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard isScoreItem(elementName), !currentTitle.isEmpty, !currentLink.isEmpty else { return }
        allMatchScores.append(ScoreItem(title: currentTitle, link: currentLink))
    }
}

private extension Array {
    subscript (safe index: Int) -> Element? {
        index >= 0 && index < count ? self[index] : nil
    }
}
