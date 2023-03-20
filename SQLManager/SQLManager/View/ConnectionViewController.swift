//
//  ConnectionViewController.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 02.03.2023.
//

import Foundation
import UIKit
import SwiftyButton
import SnapKit

class ConnectionViewController: UIViewController {
    
    private let serverAddressTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Адрес сервера БД"
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let userNameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Имя входа"
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Пароль"
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let databaseTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Название БД"
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private lazy var connectButton: FlatButton = {
        let bttn = FlatButton()
        bttn.cornerRadius = 15
        bttn.setTitle("Соединиться", for: .normal)
        bttn.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        return bttn
    }()
    
    private let databaseImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "database")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
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
    
    private let viewModel: ViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        databaseTextField.delegate = self
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        serverAddressTextField.delegate = self
        
        setupKeyboardHidding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        view.addSubview(connectButton)
        view.addSubview(serverAddressTextField)
        view.addSubview(userNameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(databaseTextField)
        view.addSubview(databaseImageView)
        
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        serverAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        databaseTextField.translatesAutoresizingMaskIntoConstraints = false
        databaseImageView.translatesAutoresizingMaskIntoConstraints = false
        
        connectButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.top.equalTo(view).offset(718)
            make.bottom.equalTo(view).offset(-46)
        }
        
        databaseTextField.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.top.equalTo(view).offset(610)
            make.bottom.equalTo(connectButton.snp.top).offset(-54)
        }
        
        passwordTextField.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.top.equalTo(view).offset(540)
            make.bottom.equalTo(databaseTextField.snp.top).offset(-24)
        }
        
        userNameTextField.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.top.equalTo(view).offset(470)
            make.bottom.equalTo(passwordTextField.snp.top).offset(-24)
        }
        
        serverAddressTextField.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.top.equalTo(view).offset(400)
            make.bottom.equalTo(userNameTextField.snp.top).offset(-24)
        }
        
        databaseImageView.snp.makeConstraints { (make) in
            make.left.equalTo(view).offset(24)
            make.right.equalTo(view).offset(-24)
            make.top.equalTo(view).offset(124)
            make.bottom.equalTo(serverAddressTextField.snp.top).offset(-24)
        }
    }
    
    @objc private func connectButtonTapped() {
        viewModel.connect(serverAddressTextField.text,
                          username: userNameTextField.text,
                          password: passwordTextField.text,
                          database: databaseTextField.text) { [weak self] result in
            do {
                guard let strongSelf = self else { return }
                
                let value = try result()
                if value {
                    guard let viewModel = self?.viewModel else { return }
                    
                    if strongSelf.isBeingPresented {
                        self?.dismiss(animated: true)
                    } else {
                        let vc = TabBarController(viewModel: viewModel)
                        vc.modalPresentationStyle = .fullScreen
                        vc.modalTransitionStyle = .flipHorizontal
                        self?.present(vc, animated: true)
                    }
                }
            } catch {
                guard let error = error as? ConnectionErrors else {
                    let alert = UIAlertController(title: "Неизвестная ошибка",
                                                  message: "",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ок",
                                                  style: .default))
                    self?.present(alert, animated: true)
                    return
                }
                switch error {
                case .emptyFields:
                    let alert = UIAlertController(title: "Укажите данные",
                                                  message: "Заполните все поля",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ок",
                                                  style: .default))
                    self?.present(alert, animated: true)
                case .connectionDenied:
                    let alert = UIAlertController(title: "Подключение отклонено",
                                                  message: "Проверьте корректность введеных данных",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ок",
                                                  style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
}

extension ConnectionViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }
}
