//
//  AddRowViewController.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 04.03.2023.
//

import Foundation
import UIKit
import SpreadsheetView

class AddRowViewController: UIViewController {
    
    private let tableSheetView: SpreadsheetView = {
        let view = SpreadsheetView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        tableSheetView.dataSource = self
        tableSheetView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.identifier)
        tableSheetView.register(TextFieldCell.self, forCellWithReuseIdentifier: TextFieldCell.identifier)
        
        viewModel.getColumnTypes(tableName: "Person", tableSchema: "Person")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(sendData))
        
        setupConstraints()
        bind()
    }
    
    private func setupConstraints() {
        view.addSubview(tableSheetView)
        
        tableSheetView.frame = view.bounds
    }
    
    private func bind() {
        viewModel.notIdentityColumnsWithDataType.bind { [weak self] _ in
            self?.tableSheetView.reloadData()
            self?.tableSheetView.layoutIfNeeded()
        }
    }
    
    @objc private func sendData() {
        
        var namesWithValues = [String: InsertModel]()
        
        for rowIndex in 0..<tableSheetView.numberOfRows {
            guard let name = (tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 0)) as? LabelCell)?.getText() else { return }
            var value: String? = (tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 1)) as? TextFieldCell)?.getText()
            if value != nil {
                if value!.isEmpty {
                    value = nil
                }
            }
            namesWithValues[name] = InsertModel(name: name, value: value)
        }

        do {
            try viewModel.sendData(tableName: "Person", tableSchema: "Person", namesWithValues: namesWithValues)
        } catch {
            guard let error = error as? AddNewValuesErrors else {
                let alert = UIAlertController(title: "Неизвестная ошибка",
                                              message: "",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок",
                                              style: .default))
                self.present(alert, animated: true)
                return
            }
            switch error {
            case .emptyFields(let fields):
                let alert = UIAlertController(title: "Заполните неободимые поля!",
                                              message: fields,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок",
                                              style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}

extension AddRowViewController: SpreadsheetViewDataSource {
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return viewModel.notIdentityColumnsWithDataType.value?.count ?? 0
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 3
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0 {
            return view.frame.width / 5 * 2
        } else if column == 1 {
            return view.frame.width / 5 * 2
        } else {
            return view.frame.width / 5
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 50
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if indexPath.column == 0 {
            let cell = tableSheetView.dequeueReusableCell(withReuseIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
            cell.setup(with: viewModel.notIdentityColumnsWithDataType.value?[indexPath.row].name ?? "")
            return cell
        } else if indexPath.column == 1 {
            let cell = tableSheetView.dequeueReusableCell(withReuseIdentifier: TextFieldCell.identifier, for: indexPath) as! TextFieldCell
            cell.setup()
            return cell
        } else {
            let cell = tableSheetView.dequeueReusableCell(withReuseIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
            cell.setup(with: viewModel.notIdentityColumnsWithDataType.value?[indexPath.row].dataType ?? "")
            return cell
        }
    }
}
