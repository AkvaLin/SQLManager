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
                        SELECT TOP 25 *
                        FROM Person.Person
                        """
}
