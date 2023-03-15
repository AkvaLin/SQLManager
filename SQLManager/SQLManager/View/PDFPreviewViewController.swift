//
//  PDFPreviewViewController.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 15.03.2023.
//

import Foundation
import UIKit
import PDFKit

class PDFPreviewViewController: UIViewController {
    
    private let pdfView: PDFView = {
        let view = PDFView()
        view.backgroundColor = .systemBackground
        view.autoScales = true
        return view
    }()
    
    public var documentData: Data?
    
    init(pdfData: Data) {
        documentData = pdfData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = documentData {
            pdfView.document = PDFDocument(data: data)
        }
        
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(sharePDF))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(pdfView)
        pdfView.frame = view.bounds
    }
    
    @objc private func sharePDF() {
        guard let data = documentData else { return }
        
        let vc = UIActivityViewController(activityItems: [data],
                                          applicationActivities: [])
        
        present(vc, animated: true)
    }
}
