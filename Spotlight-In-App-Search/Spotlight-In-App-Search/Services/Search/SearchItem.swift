//
//  SearchItem.swift
//  Spotlight-In-App-Search
//
//  Created by Michal Chobola on 24/08/2019.
//  Copyright © 2019 MajkCajk. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

extension SpotlightIndexService {
    
    /// This is helper structure for `SpotlightIndexService`.
    /// It wrappes all different structs found with `SpotlightIndexService` to be used in one array of results
    enum SearchItem {
        case first(FirstItem)
        case second(SecondItem)

        /// Spotlight search `contentType` identifier for each type of entity
        enum CategoryIdentifier: String {
            case first
            case second
        }
        
        /// Prepares `CSSearchableItem` from wrapped entity
        func createSpotlightItem() -> CSSearchableItem {
            switch self {
            case .first(let item):
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                attributeSet.contentType = CategoryIdentifier.first.rawValue
                attributeSet.title = item.name
                attributeSet.set(contentDescription: item.description)
                
                attributeSet.information = [item.name, item.description]
                    .compactMap { $0 }
                    .joined(separator: " ")

                return CSSearchableItem(uniqueIdentifier: item.id, domainIdentifier: Bundle.main.bundleIdentifier, attributeSet: attributeSet)
            case .second(let item):
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                attributeSet.contentType = CategoryIdentifier.second.rawValue
                attributeSet.title = item.name
                attributeSet.set(contentDescription: item.description)
                
                attributeSet.information = [item.name, item.description]
                    .compactMap { $0 }
                    .joined(separator: " ")

                return CSSearchableItem(uniqueIdentifier: item.id, domainIdentifier: Bundle.main.bundleIdentifier, attributeSet: attributeSet)
            }
        }
        
        /// Presentation title to be shown in in-app search results
        var title: String? {
            switch self {
            case .first(let item): return item.name
            case .second(let item): return item.name
            }
        }
        
        /// Icon image to be shown in in-app search results
        var icon: UIImage? {
            switch self {
            case .first: return UIImage(named: "first.pdf")
            case .second: return UIImage(named: "second.pdf")
            }
        }
    }
}

/// Just helpers for easier work with `CSSearchableItemAttributeSet`
fileprivate extension CSSearchableItemAttributeSet {
    
    /// Cut off given description and set it to `CSSearchableItemAttributeSet`
    ///
    /// Spotlight index in-app search is not able search thru strings that are longer than 1028 characters(don't know why). Description is the longest and the least important, so i set a boundary to 800 - approximate number. So thanks to that, the attributeSet for search ('information') filled with title, cutted desctiption, tags etc. is shorter than 1028 char.
    func set(contentDescription: String?) {
        if let contentDescription = contentDescription {
            self.contentDescription = String(contentDescription.prefix(800))
        }
    }
}

