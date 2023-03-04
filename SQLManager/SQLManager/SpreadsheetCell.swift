//
//  SpreadsheetCell.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 03.03.2023.
//

import Foundation
import SpreadsheetView
import UIKit

class SpreadsheetCell: Cell {
    
    static let identifier = "SpreadsheetCellID"
    
    private let label = UILabel()
    
    public func setup(with text: String) {
        label.text = text
        label.textAlignment = .center
        contentView.addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
}
