//
//  SearchCell.swift
//  Spotlight-In-App-Search
//
//  Created by Michal Chobola on 24/08/2019.
//  Copyright © 2019 MajkCajk. All rights reserved.
//

import UIKit

extension SearchViewController {
    
    /// Cell for `SearchViewController`.
    /// It's simple cell with image, label and separator
    final class SearchCell: UITableViewCell {
        
        // MARK: - Public properties
        
        weak var separator: UIView!
        
        var title: String? {
            didSet {
                titleLabel.text = title
            }
        }
        
        var icon: UIImage? {
            didSet {
                iconView.image = icon
            }
        }
        
        // MARK: - Private properties
        
        private var titleLabel: UILabel!
        private var iconView: UIImageView!
        
        // MARK: Initializers
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.backgroundColor = UIColor(named: "Background")

            let separator = UIView()
            separator.alpha = 0.05
            separator.backgroundColor = UIColor(named: "TextPrimary")
            contentView.addSubview(separator)
            separator.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview().inset(16)
                make.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
            self.separator = separator
            
            let iconView = UIImageView()
            iconView.tintColor = UIColor(named: "TextPrimary")?.withAlphaComponent(0.3)
            contentView.addSubview(iconView)
            iconView.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.width.height.equalTo(24)
                make.leading.equalToSuperview().inset(16)
            }
            self.iconView = iconView
            
            let titleLabel = UILabel()
            titleLabel.font = UIFont.systemFont(ofSize: 15)
            titleLabel.textColor = UIColor(named: "TextPrimary")
            titleLabel.numberOfLines = 2
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview().inset(11)
                make.bottom.equalToSuperview().inset(21)
                make.leading.equalTo(iconView.snp.trailing).offset(16)
                make.trailing.equalToSuperview().inset(16)
            }
            self.titleLabel = titleLabel
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            
            separator.isHidden = false
        }
    }
}
