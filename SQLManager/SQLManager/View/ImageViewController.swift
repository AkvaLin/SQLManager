//
//  ImageViewController.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 16.03.2023.
//

import UIKit

class ImageViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let image: UIImage
    
    init(image: UIImage) {
        self.image = image
        imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = view.bounds
        self.view.addSubview(imageView)
    }
}
