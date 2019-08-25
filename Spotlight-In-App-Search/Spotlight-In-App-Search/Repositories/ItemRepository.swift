//
//  ItemRepository.swift
//  Spotlight-In-App-Search
//
//  Created by Michal Chobola on 25/08/2019.
//  Copyright © 2019 MajkCajk. All rights reserved.
//

import ReactiveSwift

final class ItemRepository {

    lazy var allFirstItems: Property<[FirstItem]> = Property(initial: [], then: SignalProducer { (observer, lifetime) in
        var allItems = [FirstItem]()
        for index in 0..<10 {
            let item = FirstItem(id: "first \(index)", name: "First item n. \(index)", description: " ")
            allItems.append(item)
        }
        observer.send(value: allItems)
        observer.sendCompleted()
    })
    
    lazy var allSecondItems: Property<[SecondItem]> = Property(initial: [], then: SignalProducer { (observer, lifetime) in
        var allItems = [SecondItem]()
        for index in 0..<10 {
            let item = SecondItem(id: "second \(index)", name: "Second item n. \(index)", description: " ")
            allItems.append(item)
        }
        observer.send(value: allItems)
        observer.sendCompleted()
    })
}
