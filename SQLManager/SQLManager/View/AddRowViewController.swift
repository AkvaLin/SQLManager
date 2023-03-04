//
//  AddRowViewController.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 04.03.2023.
//

import Foundation
import UIKit

class AddRowViewController: UIViewController {
    
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
    }
    
    
}
