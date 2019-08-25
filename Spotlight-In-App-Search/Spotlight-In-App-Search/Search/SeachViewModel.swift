//
//  SeachViewModel.swift
//  Spotlight-In-App-Search
//
//  Created by Michal Chobola on 24/08/2019.
//  Copyright © 2019 MajkCajk. All rights reserved.
//

import ReactiveSwift

protocol SearchViewModelingActions {
    
}

protocol SearchViewModeling {
    var actions: SearchViewModelingActions { get }
    
    var foundItems: Property<[SpotlightIndexService.SearchItem]> { get }
    var searchText: MutableProperty<String> { get }
    
    var isTableViewHidden: Property<Bool> { get }
    var isNoResultLabelHidden: Property<Bool> { get }
}

extension SearchViewModeling where Self: SearchViewModelingActions {
    var actions: SearchViewModelingActions { return self }
}

/// ViewModel for `SearchViewController`.
/// Manages the search request and result data.
final class SearchViewModel: SearchViewModeling, SearchViewModelingActions {

    /// Found items from the spotlight index search
    public let foundItems: Property<[SpotlightIndexService.SearchItem]>
    
    /// Text for matching criteria to apply to indexed items
    public let searchText: MutableProperty<String>
    
    /// TableView is hidden when no result has been found
    public let isTableViewHidden: Property<Bool>
    
    /// NoResultLabel is hidden when spotlight search found something or the searchBar is empty
    public let isNoResultLabelHidden: Property<Bool>
    
    // MARK: - Initialization
    
    init(searchService: SpotlightIndexService) {
        searchText = MutableProperty("")
        
        /// For every searchText change(debounce 0.2s) it will start the search from `SpotlightIndexService` which returns SignalProducer with SearchItems
        /// It also ignore error that comes from the search.
        foundItems = Property(initial: [SpotlightIndexService.SearchItem](),
                              then: searchText
                                .producer.map { $0 }
                                .debounce(0.2, on: QueueScheduler.main)
                                .flatMap(.latest) { searchText -> SignalProducer<[SpotlightIndexService.SearchItem], Error> in
                                    return searchService.actions.search(text: searchText)
                                        .scan([], +)
                                }
                                .flatMapError { _ in .empty })
        
        isNoResultLabelHidden = Property(initial: true, then: foundItems.producer.combineLatest(with: searchText.producer.debounce(0.2, on: QueueScheduler.main))
            .map{ items, searchText in items.count != 0 || (items.count == 0 && searchText.isEmpty) })
        isTableViewHidden = Property(initial: false, then: foundItems.producer.map { $0.count == 0 })
    }
}
