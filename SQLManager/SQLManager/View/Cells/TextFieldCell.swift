//
//  AddRowVCTableViewCell.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 04.03.2023.
//

import UIKit
import SpreadsheetView

class TextFieldCell: Cell {
    
    static let identifier = "TextFieldCellID"
    
    let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .roundedRect
        return field
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textField.frame = contentView.bounds
    }
    
    public func setup() {
        textField.placeholder = "Введите значение"
        contentView.addSubview(textField)
    }
    
    public func getText() -> String? {
        return textField.text
    }
}
