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

enum AddNewValuesErrors: Error {
    case emptyFields(String)
}

enum SQLRequests: String {
    case fetchAllData = """
                        SELECT *
                        FROM tableNameWithSchema
                        """
    case getTypes = """
                    SELECT
                        COLUMN_NAME,
                        DATA_TYPE
                    FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_NAME = 'tableNameToChange' AND TABLE_SCHEMA = 'tableSchemaToChange'
                    """
    case getIdentity = "SELECT $IDENTITY FROM tableNameWithSchema"
    case getNullable = """
                        SELECT
                            COLUMN_NAME,
                            IS_NULLABLE
                        FROM INFORMATION_SCHEMA.COLUMNS
                        WHERE TABLE_NAME = 'tableNameToChange' AND TABLE_SCHEMA = 'tableSchemaToChange'
                       """
}
