//
//  ProfileViewController.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 22.03.2023.
//

import Foundation
import UIKit
import SwiftyButton
import SnapKit

class ProfileViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "database")
        return view
    }()
    
    private let databaseLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = UserDefaults.standard.database
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        return lbl
    }()
    
    private let schemaTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Table Schema"
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.text = UserDefaults.standard.tableSchema
        field.borderStyle = .roundedRect
        return field
    }()
    
    private let nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Table Name"
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.text = UserDefaults.standard.tableName
        field.borderStyle = .roundedRect
        return field
    }()
    
    private lazy var saveButton: FlatButton = {
        let bttn = FlatButton()
        bttn.cornerRadius = 15
        bttn.setTitle("Сохранить", for: .normal)
        bttn.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return bttn
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
        
        schemaTextField.delegate = self
        nameTextField.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(exitButtonTapped))
        
        setupKeyboardHidding()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupConstraints()
    }
    
    @objc private func saveButtonTapped() {
        guard let schema = schemaTextField.text,
              let name = nameTextField.text else { return }
        viewModel.changeTable(tableSchema: schema, tableName: name)
    }
    
    @objc private func exitButtonTapped() {
        let alert = UIAlertController(title: "Выход",
                                      message: "Вы уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Да",
                                      style: .destructive,
                                      handler: { [weak self] _ in
            
            guard let strongSelf = self else { return }
            strongSelf.viewModel.clearAllData()
            if strongSelf.isBeingPresented {
                strongSelf.navigationController?.popViewController(animated: true)
            } else {
                let vc = ConnectionViewController(viewModel: strongSelf.viewModel)
                vc.modalPresentationStyle = .fullScreen
                strongSelf.navigationController?.present(vc, animated: true)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Нет",
                                      style: .default))
        
        present(alert, animated: true)
    }
    
    private func setupConstraints() {
        view.addSubview(saveButton)
        view.addSubview(nameTextField)
        view.addSubview(schemaTextField)
        view.addSubview(databaseLabel)
        view.addSubview(imageView)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        schemaTextField.translatesAutoresizingMaskIntoConstraints = false
        databaseLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.top.equalTo(view).offset(688)
            make.bottom.equalTo(view).offset(-110)
        }
        
        nameTextField.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.top.equalTo(view).offset(590)
            make.bottom.equalTo(saveButton.snp.top).offset(-54)
        }
        
        schemaTextField.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.top.equalTo(view).offset(520)
            make.bottom.equalTo(nameTextField.snp.top).offset(-24)
        }
        
        databaseLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.top.equalTo(view).offset(470)
            make.bottom.equalTo(schemaTextField.snp.top).offset(-24)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.top.equalTo(view).offset(124)
            make.bottom.equalTo(databaseLabel.snp.top).offset(-24)
        }
    }
}

extension ProfileViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }
}
