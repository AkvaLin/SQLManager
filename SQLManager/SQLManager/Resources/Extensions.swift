//
//  Extensions.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 04.03.2023.
//

import Foundation

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case hostname
        case username
        case password
        case database
    }
    
    var hostname: String? {
        get {
            string(forKey: UserDefaultsKeys.hostname.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.hostname.rawValue)
        }
    }
    
    var username: String? {
        get {
            string(forKey: UserDefaultsKeys.username.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.username.rawValue)
        }
    }
    
    var password: String? {
        get {
            string(forKey: UserDefaultsKeys.password.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.password.rawValue)
        }
    }
    
    var database: String? {
        get {
            string(forKey: UserDefaultsKeys.database.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.database.rawValue)
        }
    }
}
