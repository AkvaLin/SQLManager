//
//  EditRowViewController.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 06.03.2023.
//

import Foundation
import UIKit
import SpreadsheetView

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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.setupTextFields()
        }
    }
    
    private func setupTextFields() {
        for rowIndex in 0..<tableSheetView.numberOfRows {
            guard let textFieldCell = tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 1)) as? TextFieldCell else { return }
            guard let name = (tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 0)) as? LabelCell)?.getText() else { return }
            textFieldCell.updateText(text: dataModel[name] ?? "")
        }
        self.tableSheetView.layoutIfNeeded()
    }
    
    @objc private func updateRow() {
        
    }
    
    @objc private func deleteRow() {
        viewModel.deleteRow(dictColumnNamesColumnValues: dataModel, tableName: "product", tableSchema: "dbo") { [weak self] completion in
            if completion {
                self?.viewModel.fetchTableData(tableName: "product", tableSchema: "dbo")
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
