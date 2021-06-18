//
//  String+Regex.swift
//  Swifting
//
//  Created by Varun Oberoi on 1/31/20.
//  Copyright © 2020 Varun Oberoi. All rights reserved.
//

import Foundation

extension String {
    public func replaceAll(of pattern:String,
                           with replacement:String,
                           options: NSRegularExpression.Options = []) -> String{
        do{
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            let range = NSRange(0..<self.utf16.count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
        }catch{
            NSLog("replaceAll error: \(error)")
            return self
        }
    }
    
    /// Trims whitespace from start and end of string
    ///
    /// - Returns: self with whitespace removed from start and end
    ///
    func trim() -> String {
        return trimmingCharacters(in: .whitespaces)
    }
    
    /// Strips (or removes) given character from string
    ///
    /// - Parameters:
    ///     - character: String of one character to be removed
    ///
    /// - Returns: self with character removed from string
    ///
    func strip(_ character: String) -> String {
        return replacingOccurrences(of: character, with: "")
    }
    
    /// Strips (or removes) several characters from string
    ///
    /// - Parameters:
    ///     - characters: Characters you want to be removed (one character per string!)
    ///
    /// - Returns: self with characters removed from string
    ///
    func strip(_ characters: [String]) -> String {
        var output = self
        for character in characters {
            output = replacingOccurrences(of: character, with: "")
        }
        return output
    }
    
    /// Splits a string into an array of strings with specifed components
    /// Starts at the beginning of the string and keeps splitting until end of string OR end of components.
    ///
    /// - Parameters:
    ///     - components: length of each desired substring
    ///
    /// - Returns: array of strings split into each given component lenght
    ///
    /// ```
    /// "12345".split([1, 2, 3]) == ["1", "23", "45"]
    /// ```
    ///
    //     func split(_ components: [Int]) -> [String?] {
    //         let maxIndex = index(startIndex, offsetBy: count)
    //         return components.enumerated().map { idx, length in
    //             let start = components[0..<idx].reduce(0, +)
    //             guard let startIndex = index(startIndex, offsetBy: start, limitedBy: maxIndex) else {
    //                 return nil
    //             }
    //             if startIndex == maxIndex {
    //                 return nil
    //             }
    //             let endIndex = index(startIndex, offsetBy: length, limitedBy: maxIndex) ?? maxIndex
    //             return String(self[startIndex..<endIndex])
    //         }
    //     }
    
    
    var range: NSRange { return NSRange(location: 0, length: count) }
    
    func matches(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        do {
            return try NSRegularExpression(pattern: pattern, options: options).match(in: self)
        } catch {
            return false
        }
    }
    
    func matches(regex: NSRegularExpression) -> Bool {
        return regex.match(in: self)
    }
    
    //    func isMatch(regex: String, options: NSRegularExpression.Options) -> Bool {
    //        do {
    //            let exp = try NSRegularExpression(pattern: regex, options: options)
    //            let matchCount = exp.numberOfMatches(in: self, range: NSMakeRange(0, self.count))
    //            return matchCount > 0
    //        } catch {
    //            return false
    //        }
    //    }
    //
    //    func getMatches(regex: String, options: NSRegularExpression.Options) -> [NSTextCheckingResult]
    //    {
    //        do {
    //            let exp = try NSRegularExpression(pattern: regex, options: options)
    //            let matches = exp.matches(in: self, range: NSMakeRange(0, self.count))
    //            return matches as [NSTextCheckingResult]
    //        } catch {
    //            return []
    //        }
    //    }
}

//import Foundation
//
//struct Regex {
//    var pattern: String {
//        didSet {
//            updateRegex()
//        }
//    }
//    var expressionOptions: NSRegularExpression.Options {
//        didSet {
//            updateRegex()
//        }
//    }
//    var matchingOptions: NSRegularExpression.MatchingOptions
//
//    var regex: NSRegularExpression?
//
//    init(pattern: String, expressionOptions: NSRegularExpression.MatchingOptions, matchingOptions: NSRegularExpression.MatchingOptions) {
//        self.pattern = pattern
//        self.expressionOptions = expressionOptions
//        self.matchingOptions = matchingOptions
//        updateRegex()
//    }
//
//    init(pattern: String) {
//        self.pattern = pattern
//        expressionOptions = NSRegularExpression.MatchingFlags.
//        matchingOptions = NSMatchingOptions(0)
//        updateRegex()
//    }
//
//    mutating func updateRegex() {
//        do {
//            regex = try NSRegularExpression(pattern: pattern, options: expressionOptions)
//        } catch {}
//    }
//}
//
//
//extension String {
//    func matchRegex(pattern: Regex) -> Bool {
//        let range: NSRange = NSMakeRange(0, countElements(self))
//        if pattern.regex != nil {
//            let matches: [AnyObject] = pattern.regex!.matchesInString(self, options: pattern.matchingOptions, range: range)
//            return matches.count > 0
//        }
//        return false
//    }
//
//    func match(patternString: String) -> Bool {
//        return self.matchRegex(Regex(pattern: patternString))
//    }
//
//    func replaceRegex(pattern: Regex, template: String) -> String {
//        if self.matchRegex(pattern) {
//            let range: NSRange = NSMakeRange(0, countElements(self))
//            if pattern.regex != nil {
//                return pattern.regex!.stringByReplacingMatchesInString(self, options: pattern.matchingOptions, range: range, withTemplate: template)
//            }
//        }
//        return self
//    }
//
//    func replace(pattern: String, template: String) -> String {
//        return self.replaceRegex(Regex(pattern: pattern), template: template)
//    }
//}
