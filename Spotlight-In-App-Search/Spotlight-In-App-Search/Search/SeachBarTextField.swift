//
//  SeachBarTextField.swift
//  Spotlight-In-App-Search
//
//  Created by Michal Chobola on 24/08/2019.
//  Copyright © 2019 MajkCajk. All rights reserved.
//

import UIKit
import ReactiveSwift

extension SearchViewController {
    
    /// Custom SearchBar for `SearchViewController`.
    /// Rounded, with custom clear button.
    /// Button action needs to be set
    final class SearchBarTextField: UITextField {
        
        let padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 30)
        
        weak var clearButton: UIButton!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            font = UIFont.systemFont(ofSize: 13)
            layer.cornerRadius = 24
            // TextField has border color by default, we need it clear here.
            layer.borderColor = UIColor.clear.cgColor
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 1)
            layer.shadowOpacity = 0.1
            layer.shadowRadius = 3
            
            placeholder = "Search"

            /// frame width is width + padding
            let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24 + 30, height: 24))
            clearButton.addTarget(self, action: #selector(clearButtonPressed), for: .touchUpInside)
            clearButton.setImage(UIImage(named: "close.pdf"), for: .normal)
            clearButton.contentMode = .center
            self.clearButton = clearButton
            
            rightView = clearButton
            clearButtonMode = .never
            rightViewMode = .whileEditing
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override public func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
        
        override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
        
        override public func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
        
        // MARK: - Helpers
        
        @objc
        private func clearButtonPressed() {
            self.text = ""
            self.becomeFirstResponder()
        }
        
    }
}

// MARK: Custom Operator

infix operator <~> : BindingPrecedence

/// Enables to bind MutableProperty and SearchBar both ways. Needed for in-app searching and future continue searching thru default spotlight search bar.
func <~> (property: MutableProperty<String>, textField: SearchViewController.SearchBarTextField) {
    textField.reactive.text <~ property.producer.observe(on: UIScheduler()).filter { [unowned textField] in textField.text != $0 }
    property <~ textField.reactive.continuousTextValues.map { $0 }
}

/// Enables to bind MutableProperty and SearchBar both ways. Needed for in-app searching and future continue searching thru default spotlight search bar.
func <~> (textField: SearchViewController.SearchBarTextField, property: MutableProperty<String>) {
    textField.reactive.text <~ property.producer.observe(on: UIScheduler()).filter { [unowned textField] in textField.text != $0 }
    property <~ textField.reactive.continuousTextValues.map { $0 }
}
