//
//  SpotlightIndexService.swift
//  Spotlight-In-App-Search
//
//  Created by Michal Chobola on 24/08/2019.
//  Copyright © 2019 MajkCajk. All rights reserved.
//

import CoreSpotlight
import ReactiveSwift
import MobileCoreServices

protocol SpotlightIndexServicingActions {
    func start()
    func search(text: String) -> SignalProducer<[SpotlightIndexService.SearchItem], Error>
}

protocol HasSpotlightIndexService {
    var spotlightIndexService: SpotlightIndexServicing { get }
}

protocol SpotlightIndexServicing {
    var actions: SpotlightIndexServicingActions { get }
}

extension SpotlightIndexServicing where Self: SpotlightIndexServicingActions {
    var actions: SpotlightIndexServicingActions { return self }
}

final class SpotlightIndexService: SpotlightIndexServicing, SpotlightIndexServicingActions {
    
    let itemRepository: ItemRepository
    // MARK: - Initialization
    
    init(itemRepository: ItemRepository) {
        self.itemRepository = itemRepository
    }

    // MARK: - Helpers
    
    /// Will create CSSearchableItem from every item that come from repository and index it thru func indexItems.
    /// 5 Categories are showing - Info, News, Venue, Performer & Sessions(only on conf event)
    func start() {
        itemRepository.allFirstItems.producer.observe(on: UIScheduler()).take(duringLifetimeOf: self).startWithValues { [weak self] items in
            let searchableItems = items.map { SearchItem.first($0).createSpotlightItem() }
            self?.indexItems(items: searchableItems)
        }
        itemRepository.allSecondItems.producer.observe(on: UIScheduler()).take(duringLifetimeOf: self).startWithValues { [weak self] items in
            let searchableItems = items.map { SearchItem.second($0).createSpotlightItem() }
            self?.indexItems(items: searchableItems)
        }
    }
    
    /// This SignalProducer starts a new search query and cancel it on his dispose.
    ///
    /// Property text will be trimmed for white spaces and new lines, checked if it's empty, separated by space and uniqued. So there won't be multiple searches for the same word.
    /// It will search thru "information" AttributeSet which is merged text from all searchable strings from one item like title, description, tags, custom fields etc.
    ///
    /// Values from producer are partial results from searching. For absolute result needs to be collected. Search completes after completed signal or error. Sends empty array when searched text is empty or result array is.
    ///
    /// When creating a new CSSearchQuery you need to set properties as attributes strings in case you want to have them in `attributesSet` after.
    func search(text: String) -> SignalProducer<[SearchItem], Error> {
        
        let searchableProducer: SignalProducer<[SearchItem], Error> = SignalProducer { [weak self] observer, lifetime in
            let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if text.isEmpty {
                observer.send(value: [])
                observer.sendInterrupted()
                return
            }
            
            let queryString = text.components(separatedBy: " ")
                .uniqued()
                .map { "information == \"*\($0)*\"cdt" }
                .joined(separator: " && ")
            
            let searchQuery = CSSearchQuery(queryString: queryString, attributes: ["title", "contentType"])
            
            searchQuery.foundItemsHandler = { items in
                if let searchItems = self?.createSearchItems(from: items) {
                    observer.send(value: searchItems)
                }
            }
            
            searchQuery.completionHandler = { error in
                if searchQuery.foundItemCount == 0 {
                    observer.send(value: [])
                    observer.sendInterrupted()
                    return
                }
                if let error = error {
                    assertionFailure("Spotlight searching failed")
                    observer.send(error: error)
                    return
                }
                observer.sendCompleted()
            }
            searchQuery.start()
            
            lifetime.observeEnded {
                searchQuery.cancel()
            }
            
        }
        return searchableProducer
    }
    
    /// Will create Searchable items for specific search item category.
    ///
    /// Item won't be created if the category isn't recognize.
    private func createSearchItems(from results: [CSSearchableItem]) -> [SearchItem] {
        // swiftlint:disable:previous cyclomatic_complexity
        return results.compactMap{ item -> SearchItem? in
            guard let contentType = item.attributeSet.contentType else { return nil }
            
            switch SearchItem.CategoryIdentifier(rawValue: contentType) {
            case .first?:
                guard let item = itemRepository.allFirstItems.value.first(where: { $0.id == item.uniqueIdentifier }) else { return nil }
                return SearchItem.first(item)
            case .second?:
                guard let item = itemRepository.allSecondItems.value.first(where: { $0.id == item.uniqueIdentifier }) else { return nil }
                return SearchItem.second(item)
            case .none:
                return nil
            }
        }
    }
    
    /// Will index all the SeachableItems properties to CoreSpotlight.
    ///
    /// CSSearchableIndex.isIndexingAvailable() check is no need cause indexing is not avalible on older devices than iP 4s. Also in-app search is avalible even after disabling it in Siri & Search Settings.
    private func indexItems(items: [CSSearchableItem]) {
        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let _ = error {
                assertionFailure("Spotlight indexing failed")
            }
        }
    }
}

