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
        sheet.register(SpreadsheetCell.self, forCellWithReuseIdentifier: SpreadsheetCell.identifier)
        view.backgroundColor = .systemBackground
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
            self.sheet.reloadData()
            self.sheet.layoutIfNeeded()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupConstraints()
    }
    
    func setupConstraints() {
        view.addSubview(sheet)
        
        sheet.translatesAutoresizingMaskIntoConstraints = false
        
        sheet.snp.makeConstraints { make in
            make.edges.equalTo(view).inset(UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        }
    }
}

extension MainViewController: SpreadsheetViewDataSource {
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return viewModel.tableData.count + 1
    }
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return viewModel.tableHeaders.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 150
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 30
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        let cell = sheet.dequeueReusableCell(withReuseIdentifier: SpreadsheetCell.identifier, for: indexPath) as! SpreadsheetCell

        if indexPath.row == 0 {
            cell.setup(with: viewModel.tableHeaders[indexPath.column])
        } else {
            cell.setup(with: viewModel.tableData[indexPath.row - 1][indexPath.column])
        }

        return cell
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        if viewModel.tableData.count > 0 {
            return 1
        } else {
            return 0
        }
    }
}
