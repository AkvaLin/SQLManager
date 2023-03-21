//
//  DatePickerCell.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 17.03.2023.
//

import Foundation
import SpreadsheetView
import UIKit

class DatePickerCell: Cell {
    
    static let identifier = "DatePickerCellID"
    
    private let picker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.date = Date()
        picker.preferredDatePickerStyle = .compact
        return picker
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .systemBackground
        
        contentView.addSubview(picker)
        picker.frame = contentView.bounds
    }
    
    public func setup(date: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        picker.date = formatter.date(from: date) ?? Date()
    }
    
    public func getStringDate() -> String {
        return picker.date.formatted(.iso8601)
    }
}
