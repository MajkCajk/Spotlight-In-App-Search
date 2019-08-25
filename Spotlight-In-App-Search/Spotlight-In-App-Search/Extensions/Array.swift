//
//  Array.swift
//  Spotlight-In-App-Search
//
//  Created by Michal Chobola on 25/08/2019.
//  Copyright © 2019 MajkCajk. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    
    /// Will filter all duplicated elements in array.
    ///
    /// Used for filtering duplicated words in searched text for Spotlight search.
    ///
    /// source: https://stackoverflow.com/questions/27624331/unique-values-of-array-in-swift
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}
