//
//  NSRegularExpression+match.swift
//  Swifting
//
//  Created by Varun Oberoi on 2/1/20.
//  Copyright © 2020 Varun Oberoi. All rights reserved.
//
import Foundation

extension NSRegularExpression {
    convenience init(substrings: [String], options: NSRegularExpression.Options) throws {
        let escapedSubstrings: [String] = substrings.map(NSRegularExpression.escapedTemplate)
        let pattern: String = escapedSubstrings.joined(separator: "|")
        try self.init(pattern: pattern, options: options)
    }

    convenience init?(with pattern: String, options: NSRegularExpression.Options = []) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            return nil
        }
    }

    func match(in input: String) -> Bool {
        return numberOfMatches(in: input, options: [], range: input.range) > 0
    }
    
    func split(_ str: String) -> [String] {
        let range = NSRange(location: 0, length: str.count)
        
        //get locations of matches
        var matchingRanges: [NSRange] = []
        let matches: [NSTextCheckingResult] = self.matches(in: str, options: [], range: range)
        for match: NSTextCheckingResult in matches {
            matchingRanges.append(match.range)
        }
        
        //invert ranges - get ranges of non-matched pieces
        var pieceRanges: [NSRange] = []
        
        //add first range
        pieceRanges.append(NSRange(location: 0, length: (matchingRanges.count == 0 ? str.count : matchingRanges[0].location)))
        
        //add between splits ranges and last range
        for i in 0..<matchingRanges.count {
            let isLast = i + 1 == matchingRanges.count
            
            let location = matchingRanges[i].location
            let length = matchingRanges[i].length
            
            let startLoc = location + length
            let endLoc = isLast ? str.count : matchingRanges[i + 1].location
            pieceRanges.append(NSRange(location: startLoc, length: endLoc - startLoc))
        }
        
        var pieces: [String] = []
        for range: NSRange in pieceRanges {
            let piece = (str as NSString).substring(with: range)
            pieces.append(piece)
        }
        
        return pieces
    }

}
