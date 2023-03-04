//
//  Constants.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 02.03.2023.
//

import Foundation

enum ConnectionErrors: Error {
    case emptyFields
    case connectionDenied
}

enum SQLRequests: String {
    case fetchAllData = """
                        SELECT TOP 10000 *
                        FROM Person.Person
                        """
}
