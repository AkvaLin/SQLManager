//
//  ViewController.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 01.03.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let viewModel: ViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

