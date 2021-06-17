//
//  Match.swift
//  Swifting
//
//  Created by Varun Oberoi on 1/5/20.
//  Copyright © 2020 Varun Oberoi. All rights reserved.
//

struct Match: Hashable, Codable {
    var title: String
    var link: String
    var status: String
    var summary: String
    var teams: [Team]
    var shortScore: String
    var fromPage: Bool
    var matchStarted: Bool
}

struct Team: Hashable, Codable {
    var name: String
    var scores: [Score]
    var batting: Bool
}

struct Score: Hashable, Codable {
    var score: String
    var overs: String
}
