//
//  TabBarController.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 04.03.2023.
//

import UIKit

class TabBarController: UITabBarController {
    
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    init() {
        self.viewModel = ViewModel()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        connect()
    }
    
    private func setupViewControllers() {
        viewControllers = [
            createNavController(for: MainViewController(viewModel: viewModel), image: UIImage())
        ]
    }
    
    private func createNavController(for rootViewController: UIViewController, image: UIImage) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = image
        return navController
    }
    
    private func connect() {
        viewModel.connect(UserDefaults.standard.hostname, username: UserDefaults.standard.username, password: UserDefaults.standard.password, database: UserDefaults.standard.database) { [weak self] result in
            guard let stronSelf = self else { return }
            do {
                let value = try result()
                if value {
                    DispatchQueue.global(qos: .userInteractive).async {
                        stronSelf.viewModel.fetchTableData()
                    }
                }
            } catch {
                if stronSelf.isBeingPresented {
                    self?.dismiss(animated: true)
                } else {
                    let vc = ConnectionViewController(viewModel: stronSelf.viewModel)
                    vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .flipHorizontal
                    self?.present(vc, animated: true)
                }
            }
        }
    }
}
