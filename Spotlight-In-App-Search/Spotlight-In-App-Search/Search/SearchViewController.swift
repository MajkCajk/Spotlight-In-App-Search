//
//  SearchViewController.swift
//  Spotlight-In-App-Search
//
//  Created by Michal Chobola on 03/08/2019.
//  Copyright © 2019 MajkCajk. All rights reserved.
//

import UIKit
import SnapKit
import CoreSpotlight
import ReactiveSwift
import ReactiveCocoa

/// This Controller enable to search thru spotlight indexes.
/// Indexes and search is managed in SpotlightIndexService
/// 2 Categories are showing - First and Second.
final class SearchViewController: UIViewController {
    
    // MARK: - Properties

    private weak var tableView: UITableView!
    private weak var searchBar: SearchBarTextField!
    private weak var noResultLabel: UILabel!
    private weak var viewForShadow: UIView!
    
    private weak var bottomView: UIView!
    
    private let viewModel: SearchViewModel

    // MARK: Initializers
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor(named: "Background")

        // View for searchBar shadow
        let viewForShadow = UIView()
        viewForShadow.layer.shadowRadius = 5
        viewForShadow.isUserInteractionEnabled = true
        viewForShadow.backgroundColor = UIColor(named: "Background")
        viewForShadow.layer.shadowColor = UIColor(named: "TextPrimary")?.cgColor
        view.addSubview(viewForShadow)
        viewForShadow.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        self.viewForShadow = viewForShadow
        
        let searchBar = SearchBarTextField()
        searchBar.backgroundColor = UIColor(named: "Foreground")
        searchBar.textColor = UIColor(named: "TextPrimary")?.withAlphaComponent(0.6)
        searchBar.rightView?.tintColor = UIColor(named: "Secondary")
        viewForShadow.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(68)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(24)
        }
        self.searchBar = searchBar
        
        // View under the SearchBar for TableView and noResultLabel.
        let bottomView = UIView()
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(viewForShadow.snp.bottom)
            make.leading.bottom.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        self.bottomView = bottomView
        
        let tableView = UITableView()
        tableView.register(SearchCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor(named: "Background")
        tableView.separatorStyle = .none
        tableView.isOpaque = false
        bottomView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.tableView = tableView
        
        let noResultLabel = UILabel()
        noResultLabel.isHidden = true
        noResultLabel.text = "No result"
        noResultLabel.font = UIFont.systemFont(ofSize: 15)
        noResultLabel.textColor = UIColor(named: "TextPrimary")?.withAlphaComponent(0.7)
        noResultLabel.textAlignment = .center
        bottomView.addSubview(noResultLabel)
        noResultLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        self.noResultLabel = noResultLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        setupTableViewScrollingShadow()

        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
    }
    
    // MARK: - Helpers
    
    private func setupBindings() {
        tableView.reactive.isHidden <~ viewModel.isTableViewHidden
        noResultLabel.reactive.isHidden <~ viewModel.isNoResultLabelHidden
        tableView.reactive.reloadData <~ viewModel.foundItems.map { _ in }
        
        // Bind textField and MutablyProperty that triggers search action
        viewModel.searchText <~> searchBar
    }
    
    /// will dismiss keyboard when user taps on view
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        searchBar.endEditing(true)
    }
    
    /// Handles shadow on the bottom line of viewForShadow when tableView is scrolling.
    private func setupTableViewScrollingShadow() {
        let contentSizeSignal = tableView.reactive.signal(forKeyPath: "contentSize").map { [weak tableView] _ -> Any? in tableView?.bounds }
        let boundsSignal = tableView.reactive.signal(forKeyPath: "bounds")
        Signal.merge([contentSizeSignal, boundsSignal]).observeValues { [weak self] bounds in
            guard let bounds = bounds as? CGRect else { return }
            
            self?.viewForShadow.layer.shadowOpacity = (Float(min(bounds.origin.y, 20)/20.0)) * 0.4
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.foundItems.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? SearchCell else {
            return UITableViewCell()
        }
        cell.icon = viewModel.foundItems.value[indexPath.row].icon
        cell.title = viewModel.foundItems.value[indexPath.row].title
        return cell
    }
}

