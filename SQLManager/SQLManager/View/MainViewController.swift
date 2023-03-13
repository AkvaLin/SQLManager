//
//  ViewController.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 01.03.2023.
//

import UIKit
import SpreadsheetView

class MainViewController: UIViewController {
    
    private let sheet: SpreadsheetView = {
        let view = SpreadsheetView()
        view.backgroundColor = .systemBackground
        view.allowsSelection = true
        view.allowsMultipleSelection = false
        return view
    }()
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let viewModel: ViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        sheet.dataSource = self
        sheet.delegate = self
        sheet.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.identifier)
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(updateData))
        
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        view.addSubview(sheet)
        
        sheet.translatesAutoresizingMaskIntoConstraints = false
        
        sheet.snp.makeConstraints { make in
            make.edges.equalTo(view).inset(UIEdgeInsets(top: 40, left: 0, bottom: 50, right: 0))
        }
    }
    
    private func bind() {
        viewModel.tableData.bind { [weak self] _ in
            self?.sheet.reloadData()
            self?.sheet.layoutIfNeeded()
        }
    }
    
    @objc func updateData() {
        viewModel.fetchTableData()
    }
}

extension MainViewController: SpreadsheetViewDataSource {
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return (viewModel.tableData.value?.count ?? -1) + 1
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return viewModel.tableHeaders.value?.count ?? 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 150
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 30
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let cell = sheet.dequeueReusableCell(withReuseIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell

        if indexPath.row == 0 {
            cell.setup(with: viewModel.tableHeaders.value?[indexPath.column] ?? "")
        } else {
            cell.setup(with: viewModel.tableData.value?[indexPath.row - 1][indexPath.column] ?? "")
        }

        return cell
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        if viewModel.tableData.value?.count ?? -1 > 0 {
            return 1
        } else {
            return 0
        }
    }
}

extension MainViewController: SpreadsheetViewDelegate {
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row != 0 {
            var dataModel = [String: String]()
            
            for columnIndex in 0..<spreadsheetView.numberOfColumns {
                guard let columnName = viewModel.tableHeaders.value?[columnIndex] else { return }
                dataModel[columnName] = viewModel.tableData.value?[indexPath.row - 1][columnIndex] ?? ""
            }
            
            let vc = EditRowViewController(viewModel: viewModel, dataModel: dataModel)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
