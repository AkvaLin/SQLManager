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
    
    internal let tableSheetView: SpreadsheetView = {
        let view = SpreadsheetView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let networkView: UILabel = {
        let view = UILabel()
        view.backgroundColor = .systemGreen
        view.text = "Запрос успешно отправлен"
        view.numberOfLines = 0
        view.textColor = .white
        view.textAlignment = .center
        view.alpha = 0
        return view
    }()
    
    internal let viewModel: ViewModel
    
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
        tableSheetView.register(DatePickerCell.self, forCellWithReuseIdentifier: DatePickerCell.identifier)
        tableSheetView.register(ImagePickerCell.self, forCellWithReuseIdentifier: ImagePickerCell.identifier)
        
        viewModel.getColumnTypes()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "paperplane"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(addRow))
        
        navigationItem.title = "Добавление"
        
        setupConstraints()
        bind()
        hideKeyboardWhenTappedAround()
        setupKeyboardHidding()
    }
    
    private func setupConstraints() {
        view.addSubview(tableSheetView)
        view.addSubview(networkView)
        
        tableSheetView.frame = view.bounds
        
        networkView.translatesAutoresizingMaskIntoConstraints = false
        networkView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        networkView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        networkView.topAnchor.constraint(equalTo: view.topAnchor, constant: 700).isActive = true
        networkView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90).isActive = true
    }
    
    private func bind() {
        viewModel.notIdentityColumnsWithDataType.bind { [weak self] _ in
            self?.tableSheetView.reloadData()
            self?.tableSheetView.layoutIfNeeded()
        }
    }
    
    @objc private func addRow() {
        
        var namesWithValues = [String: InsertModel]()
        
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
            namesWithValues[name] = InsertModel(name: name, value: value)
        }

        do {
            try viewModel.addRow(namesWithValues: namesWithValues) { [weak self] completion in
                if completion {
                    self?.viewModel.fetchTableData()
                    for rowIndex in 0..<(self?.tableSheetView.numberOfRows ?? 0) {
                        DispatchQueue.main.async {
                            (self?.tableSheetView.cellForItem(at: IndexPath(row: rowIndex, column: 1)) as? TextFieldCell)?.clear()
                            UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options: .curveEaseInOut) {
                                self?.networkView.alpha = 1
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)) {
                                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1, options: .curveEaseInOut) {
                                    self?.networkView.alpha = 0
                                }
                            }
                        }
                    }
                }
            }
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
            guard let type = viewModel.notIdentityColumnsWithDataType.value?[indexPath.row].dataType else { return tableSheetView.dequeueReusableCell(withReuseIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell}
            if type == "date" {
                let cell = tableSheetView.dequeueReusableCell(withReuseIdentifier: DatePickerCell.identifier, for: indexPath) as! DatePickerCell
                return cell
            } else if type == "text" {
                let cell = tableSheetView.dequeueReusableCell(withReuseIdentifier: ImagePickerCell.identifier, for: indexPath) as! ImagePickerCell
                return cell
            } else {
                let cell = tableSheetView.dequeueReusableCell(withReuseIdentifier: TextFieldCell.identifier, for: indexPath) as! TextFieldCell
                cell.setup(delegate: self)
                return cell
            }
        } else {
            let cell = tableSheetView.dequeueReusableCell(withReuseIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
            cell.setup(with: viewModel.notIdentityColumnsWithDataType.value?[indexPath.row].dataType ?? "")
            return cell
        }
    }
}

extension AddRowViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }
}
