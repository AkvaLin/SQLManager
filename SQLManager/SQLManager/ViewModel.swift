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
    
    public var tableData: Observable<[[String]]> = Observable([[String]]())
    public var tableHeaders: Observable<[String]> = Observable([String]())
    
    func connect(_ host: String?, username: String?, password: String?, database: String?, callback: @escaping (ThrowsCallback) -> Void) {
        
        guard !client.isConnected() else {
            callback( { return client.isConnected() })
            return
        }
        
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
                    UserDefaults.standard.hostname = nil
                    UserDefaults.standard.username = nil
                    UserDefaults.standard.password = nil
                    UserDefaults.standard.database = nil
                    callback( { throw ConnectionErrors.connectionDenied } )
                } else {
                    UserDefaults.standard.hostname = hostname
                    UserDefaults.standard.username = username
                    UserDefaults.standard.password = password
                    UserDefaults.standard.database = database
                    callback( { return isConnected } )
                }
            }
        }
    }
    
    func fetchTableData() {
        guard client.isConnected() else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.client.execute(SQLRequests.fetchAllData.rawValue) { result in
                // check data for nil and get keys
                guard let data = result?[0] as? NSArray else { return }
                guard let keys = (data[0] as? NSDictionary)?.allKeys else { return }
                guard let stringKeys = keys as? [String] else { return }
                // dict keys -- sql table headers
                self.tableHeaders.value = stringKeys
                // transform all data to string and store it
                self.tableData.value = data
                    .compactMap { $0 as? NSDictionary }
                    .compactMap { $0.allValues }
                    .compactMap { $0.compactMap { "\($0)" } }
            }
        }
    }
}
