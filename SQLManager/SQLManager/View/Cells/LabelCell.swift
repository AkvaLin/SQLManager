//
//  SpreadsheetCell.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 03.03.2023.
//

import Foundation
import SpreadsheetView
import UIKit

class LabelCell: Cell {
    
    static let identifier = "LabelCellID"
    
    private let label = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
    public func setup(with text: String) {
        label.text = text
        label.textAlignment = .center
        contentView.addSubview(label)
    }
    
    public func getText() -> String? {
        return label.text
    }
}
