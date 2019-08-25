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
            case categoryOne
            case categoryTwo
        }
        
        /// Prepares `CSSearchableItem` from wrapped entity
        func createSpotlightItem() -> CSSearchableItem {
            switch self {
            case .first(let item):
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                attributeSet.contentType = CategoryIdentifier.categoryOne.rawValue
                attributeSet.title = item.name
                attributeSet.contentDescription = item.description
                
                attributeSet.information = [item.name, item.description]
                    .compactMap { $0 }
                    .joined(separator: " ")

                return CSSearchableItem(uniqueIdentifier: item.id, domainIdentifier: Bundle.main.bundleIdentifier, attributeSet: attributeSet)
            case .second(let item):
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                attributeSet.contentType = CategoryIdentifier.categoryTwo.rawValue
                attributeSet.title = item.name
                attributeSet.contentDescription = item.description

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
