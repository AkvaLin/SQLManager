//
//  ConnectionViewModel.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 02.03.2023.
//

import Foundation
import SQLClient

class ViewModel {
    
    private let client = SQLClient()
    
    typealias ThrowsCallback = () throws -> (Bool)
    
    func connect(_ host: String?, username: String?, password: String?, database: String?, callback: @escaping (ThrowsCallback) -> Void) {
        
        guard let hostname = host, !hostname.isEmpty else {
            callback( { throw ConnectionErrors.emptyFields } )
            return
        }
        guard let username = username, !username.isEmpty else {
            callback( { throw ConnectionErrors.emptyFields } )
            return
        }
        guard let password = password, !password.isEmpty else {
            callback( { throw ConnectionErrors.emptyFields } )
            return
        }
        guard let database = database, !database.isEmpty else {
            callback( { throw ConnectionErrors.emptyFields } )
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.client.connect(hostname, username: username, password: password, database: database) { isConnected in
                if !isConnected {
                    callback( { throw ConnectionErrors.connectionDenied } )
                } else {
                    callback( { return isConnected } )
                }
            }
        }
    }
    
}
