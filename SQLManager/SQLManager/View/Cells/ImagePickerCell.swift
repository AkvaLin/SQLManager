//
//  ImagePickerCell.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 17.03.2023.
//

import Foundation
import SpreadsheetView
import UIKit

class ImagePickerCell: Cell {
    
    static let identifier = "ImagePickerCellID"
    
    private var image: UIImage? = nil
    private var pickedImageStringData: String = ""
    
    private var columnName = ""
    private var dataModel = [String: String]()
    
    private var viewModel = ViewModel()
    
    private let showButton: UIButton = {
        let bttn = UIButton()
        bttn.setImage(UIImage(systemName: "photo"), for: .normal)
        bttn.addTarget(self, action: #selector(showButtonTapped), for: .touchUpInside)
        return bttn
    }()
    
    private let pickButton: UIButton = {
        let bttn = UIButton()
        bttn.setImage(UIImage(systemName: "pencil"), for: .normal)
        bttn.addTarget(self, action: #selector(pickButtonTapped), for: .touchUpInside)
        return bttn
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(showButton)
        contentView.addSubview(pickButton)
        
        showButton.translatesAutoresizingMaskIntoConstraints = false
        pickButton.translatesAutoresizingMaskIntoConstraints = false
        
        showButton.snp.makeConstraints { make in
            make.leading.equalTo(contentView)
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.width.equalTo(contentView.frame.width/2)
        }
        pickButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView)
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView)
            make.width.equalTo(contentView.frame.width/2)
        }
    }
    
    @objc private func pickButtonTapped() {
        guard let parentViewController = parentViewController else { return }
        
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        
        parentViewController.present(vc, animated: true)
    }
    
    @objc private func showButtonTapped() {
        guard let parentViewController = parentViewController else { return }
        
        if let image = image {
            let imageViewController = ImageViewController(image: image)
            parentViewController.navigationController?.pushViewController(imageViewController, animated: true)
        } else {
            viewModel.getImage(tableName: "product", tableSchema: "dbo", columnName: columnName, dataModel: dataModel) { image in
                guard let image = image else {
                    let alert = UIAlertController(title: "Изображение отсутствует", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ок", style: .default))
                    parentViewController.present(alert, animated: true)
                    return
                }
                let imageViewController = ImageViewController(image: image)
                parentViewController.navigationController?.pushViewController(imageViewController, animated: true)
            }
        }
    }
    
    public func setup(columName: String, dataModel: [String: String], viewModel: ViewModel) {
        self.columnName = columName
        self.dataModel = dataModel
        self.viewModel = viewModel
    }
    
    public func getImageData() -> String {
        return pickedImageStringData
    }
}

extension ImagePickerCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            self.image = image
            guard let data = image.jpegData(compressionQuality: 0.1) else { return }
            pickedImageStringData = data.base64EncodedString()
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
