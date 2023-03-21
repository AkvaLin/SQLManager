//
//  EditRowViewController.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 06.03.2023.
//

import Foundation
import UIKit
import SpreadsheetView
import KRProgressHUD

class EditRowViewController: AddRowViewController {
    
    private let dataModel: [String: String]
    
    init(viewModel: ViewModel, dataModel: [String: String]) {
        self.dataModel = dataModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "paperplane"), style: .plain, target: self, action: #selector(updateRow)),
            UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteRow))
        ]
        
        navigationItem.title = "Редактирование"
        
        KRProgressHUD
            .set(activityIndicatorViewColors: [.systemBlue, .systemMint])
            .set(style: .custom(background: .systemGray5, text: .label, icon: .clear))
            .show(withMessage: "Загрузка...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.setupTextFields()
            KRProgressHUD.dismiss()
        }
    }
    
    private func setupTextFields() {
        for rowIndex in 0..<tableSheetView.numberOfRows {
            guard let dataTypeCell = tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 2)) as? LabelCell else { return }
            guard let name = (tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 0)) as? LabelCell)?.getText() else { return }
            switch dataTypeCell.getText() {
            case "text":
                guard let cell = tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 1)) as? ImagePickerCell else { return }
                cell.setup(columName: name, dataModel: dataModel, viewModel: viewModel)
            case "date":
                guard let cell = tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 1)) as? DatePickerCell else { return }
                cell.setup(date: dataModel[name] ?? "")
            default:
                guard let textFieldCell = tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 1)) as? TextFieldCell else { return }
                textFieldCell.updateText(text: dataModel[name] ?? "")
            }
        }
        self.tableSheetView.layoutIfNeeded()
    }
    
    @objc private func updateRow() {
        
        var namesWithValues = [String: String]()
        
        for rowIndex in 0..<tableSheetView.numberOfRows {
            guard let name = (tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 0)) as? LabelCell)?.getText() else { return }
            guard let dataType = (tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 2)) as? LabelCell)?.getText() else { return }
            var value: String? = nil
            switch dataType {
            case "text":
                value = (tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 1)) as? ImagePickerCell)?.getImageData()
            case "date":
                value = (tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 1)) as? DatePickerCell)?.getStringDate()
            default:
                value = (tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 1)) as? TextFieldCell)?.getText()
            }
            if value != nil {
                if value!.isEmpty {
                    value = nil
                }
            }
            namesWithValues[name] = value
        }
        
        viewModel.updateRow(prevValues: dataModel, newValues: namesWithValues) { [weak self] completion in
            if completion {
                self?.viewModel.fetchTableData()
            }
        }
    }
    
    @objc private func deleteRow() {
        viewModel.deleteRow(dictColumnNamesColumnValues: dataModel) { [weak self] completion in
            if completion {
                self?.viewModel.fetchTableData()
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
