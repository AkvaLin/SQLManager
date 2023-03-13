//
//  ConnectionViewModel.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 02.03.2023.
//

import Foundation
import SQLClient

class ViewModel {
    
    private let sqlClient = SQLClient()
    
    typealias ThrowsCallback = () throws -> (Bool)
    
    public var tableData: Observable<[[String]]> = Observable([[String]]())
    public var tableHeaders: Observable<[String]> = Observable([String]())
    public var notIdentityColumnsWithDataType: Observable<[ColumnDataTypeModel]> = Observable([ColumnDataTypeModel]())
    
    func connect(_ host: String?, username: String?, password: String?, database: String?, callback: @escaping (ThrowsCallback) -> Void) {
        
        guard !sqlClient.isConnected() else {
            callback( { return sqlClient.isConnected() })
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
            self?.sqlClient.connect(hostname, username: username, password: password, database: database) { isConnected in
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
    
    func fetchTableData(tableName: String = "product", tableSchema: String = "dbo") {
        guard sqlClient.isConnected() else { return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.sqlClient.execute(self.changeDBName(from: SQLRequests.fetchAllData.rawValue, with: tableName, and: tableSchema)) { result in
                // check data for nil and get keys
                guard let data = result?.first as? NSArray else { return }
                guard let keys = (data.firstObject as? NSDictionary)?.allKeys else { return }
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
    
    private func changeDBName(from request: String, with tableName: String, and schemaName: String) -> String {
        var replacedString = request
        replacedString = replacedString.replacingOccurrences(of: "tableNameWithSchema", with: "\(schemaName).\(tableName)")
        replacedString = replacedString.replacingOccurrences(of: "tableNameToChange", with: tableName)
        replacedString = replacedString.replacingOccurrences(of: "tableSchemaToChange", with: schemaName)
        return replacedString
    }
    
    public func sendData(tableName: String, tableSchema: String, namesWithValues: [String: InsertModel], completion: @escaping (Bool) -> Void) throws {
        let notNullable = getNotNullableColumns()
        var emptyFields = [String]()
        notNullable.forEach { name in
            guard let fieldValue = namesWithValues[name] else {
                emptyFields.append(name)
                return
            }
            guard let value = fieldValue.value else {
                emptyFields.append(name)
                return
            }
            if value.isEmpty {
                emptyFields.append(name)
            }
        }
        guard emptyFields.isEmpty else {
            completion(false)
            throw AddNewValuesErrors.emptyFields(emptyFields.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: ""))
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let names = namesWithValues.values.map { $0.name }
            let values = namesWithValues.values.map { $0.value }
            let namesString = names.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "\"", with: "")
            let valuesString = values.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "\"", with: "\'").replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "nil", with: "NULL")
            self.sqlClient.execute("INSERT INTO \(tableSchema).\(tableName) (\(namesString)) VALUES (\(valuesString))")
            completion(true)
        }
    }
    
    public func deleteRow(dictColumnNamesColumnValues: [String: String], tableName: String, tableSchema: String, completion: @escaping(Bool) -> Void) {
        
        var dict = dictColumnNamesColumnValues
        
        dictColumnNamesColumnValues.forEach { (key, value) in
            if value.contains("xml") {
                dict.removeValue(forKey: key)
            } else if value == "<null>" {
                dict.removeValue(forKey: key)
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var request = "DELETE FROM \(tableSchema).\(tableName) WHERE "
            dict.forEach { (key, value) in
                request += "\(key) = \'\(value)\' and "
            }
            if request.last == " " {
                for _ in 0...3 {
                    request.removeLast()
                }
            }
            self.sqlClient.execute(request)
            completion(true)
        }
    }
    
}

// MARK: - Get Methods
extension ViewModel {
    
    public func getColumnTypes(tableName: String, tableSchema: String) {
        guard sqlClient.isConnected() else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.sqlClient.execute(self.changeDBName(from: SQLRequests.getTypes.rawValue, with: tableName, and: tableSchema)) { result in
                guard let array = result else { return }
                guard let nsArray = array.first as? NSArray else { return }
                var models = [ColumnDataTypeModel]()
                
                self.getIdentityColumns(tableName: tableName, tableSchema: tableSchema) { name in
                    let identityColumnName = name != nil ? name! : ""
                    self.getNullableColumns(tableName: tableName, tableSchema: tableSchema) { nullableDict in
                        guard !nullableDict.isEmpty else { return }
                        nsArray.forEach { element in
                            guard let dict = element as? NSDictionary else { return }
                            guard let name = dict.object(forKey: "COLUMN_NAME") as? String else { return }
                            guard let dataType = dict.object(forKey: "DATA_TYPE") as? String else { return }
                            if !(identityColumnName == name) {
                                models.append(ColumnDataTypeModel(name: name,
                                                                  dataType: dataType,
                                                                  isNullable: nullableDict[name] ?? false))
                            }
                        }
                        self.notIdentityColumnsWithDataType.value = models
                    }
                }
            }
        }
    }
    
    private func getIdentityColumns(tableName: String, tableSchema: String, clouser: @escaping (String?) -> Void) {

        DispatchQueue.global(qos: .userInitiated).async {
            self.sqlClient.execute(self.changeDBName(from: SQLRequests.getIdentity.rawValue, with: tableName, and: tableSchema)) { result in
                guard let array = result else { clouser(nil); return }
                guard let firstElement = array.first else { clouser(nil); return }
                guard let nsArray = firstElement as? NSArray else { clouser(nil); return }
                guard let firstObject = nsArray.firstObject as? NSDictionary else { clouser(nil); return }
                guard let key = firstObject.allKeys.first as? String else { clouser(nil); return }
                clouser(key)
            }
        }
    }
    
    private func getNullableColumns(tableName: String, tableSchema: String, clouser: @escaping ([String: Bool]) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.sqlClient.execute(self.changeDBName(from: SQLRequests.getNullable.rawValue, with: tableName, and: tableSchema)) { result in
                guard let array = result else { clouser([:]); return }
                guard let firstElement = array.first else { clouser([:]); return }
                guard let nsArray = firstElement as? NSArray else { clouser([:]); return }
                var escapingValue = [String: Bool]()
                nsArray.forEach { frozenDict in
                    guard let dict = frozenDict as? NSDictionary else { clouser([:]); return }
                    if "NO" == "\(dict.value(forKey: "IS_NULLABLE") ?? "")" {
                        escapingValue.updateValue(false, forKey: "\(dict.value(forKey: "COLUMN_NAME") ?? "")")
                    } else {
                        escapingValue.updateValue(true, forKey: "\(dict.value(forKey: "COLUMN_NAME") ?? "")")
                    }
                }
                clouser(escapingValue)
            }
        }
    }
    
    private func getNotNullableColumns() -> [String] {
        var namesOfNotNullableColumns = [String]()
        notIdentityColumnsWithDataType.value?.forEach({ model in
            if !model.isNullable {
                namesOfNotNullableColumns.append(model.name)
            }
        })
        return namesOfNotNullableColumns
    }
}
