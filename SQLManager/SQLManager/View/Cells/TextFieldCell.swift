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
    
    public func setup(delegate: UITextFieldDelegate) {
        textField.placeholder = "Введите значение"
        textField.delegate = delegate
        contentView.addSubview(textField)
    }
    
    public func updateText(text: String) {
        textField.text = text
        contentView.layoutIfNeeded()
    }
    
    public func getText() -> String? {
        return textField.text
    }
    
    public func clear() {
        textField.text = ""
    }
}
