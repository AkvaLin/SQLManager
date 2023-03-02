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
        return tf
    }()
    
    private let userNameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Имя входа"
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Пароль"
        return tf
    }()
    
    private let databaseTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Название БД"
        return tf
    }()
    
    private let connectButton: FlatButton = {
        let bttn = FlatButton()
        bttn.cornerRadius = 15
        bttn.setTitle("Соединиться", for: .normal)
        return bttn
    }()
    
    private let databaseImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "database")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
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
    
}
