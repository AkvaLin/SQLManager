//
//  ConnectionViewModel.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 02.03.2023.
//

import Foundation
import SQLClient
import PDFKit

class ViewModel {
    
    private let sqlClient = SQLClient()
    
    typealias ThrowsCallback = () throws -> (Bool)
    
    public var tableData: Observable<[[String]]> = Observable([[String]]())
    public var tableHeaders: Observable<[String]> = Observable([String]())
    public var notIdentityColumnsWithDataType: Observable<[ColumnDataTypeModel]> = Observable([ColumnDataTypeModel]())
    
    func connect(_ host: String?, username: String?, password: String?, database: String?, callback: @escaping (ThrowsCallback) -> Void) {
        sqlClient.maxTextSize = 2147483647
        
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
    
    func fetchTableData(tableName: String = UserDefaults.standard.tableName ?? "",
                        tableSchema: String = UserDefaults.standard.tableSchema ?? "") {
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
    
    public func addRow(tableName: String = UserDefaults.standard.tableName ?? "",
                       tableSchema: String = UserDefaults.standard.tableSchema ?? "",
                       namesWithValues: [String: InsertModel],
                       completion: @escaping (Bool) -> Void) throws {
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
    
    public func deleteRow(dictColumnNamesColumnValues: [String: String],
                          tableName: String = UserDefaults.standard.tableName ?? "",
                          tableSchema: String = UserDefaults.standard.tableSchema ?? "",
                          completion: @escaping(Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var request = "DELETE FROM \(tableSchema).\(tableName) WHERE "
            request += self.getWhereStatement(keyValue: dictColumnNamesColumnValues)
            self.sqlClient.execute(request)
            completion(true)
        }
    }
    
    public func updateRow(prevValues: [String: String],
                          newValues: [String: String],
                          tableName: String = UserDefaults.standard.tableName ?? "",
                          tableSchema: String = UserDefaults.standard.tableSchema ?? "",
                          completion: @escaping(Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var request = "UPDATE \(tableSchema).\(tableName) SET "
            guard let identityColumns = self.notIdentityColumnsWithDataType.value else { return }
            newValues.forEach { (key: String, value: String) in
                if identityColumns.contains(where: { model in
                    model.name == key
                }) {
                    request += "\(key) = \'\(value)\', "
                }
            }
            request.removeLast(2)
            request += " WHERE "
            request += self.getWhereStatement(keyValue: prevValues)
            self.sqlClient.execute(request)
            completion(true)
        }
    }
    
    public func getImage(tableName: String,
                         tableSchema: String,
                         columnName: String,
                         dataModel: [String: String],
                         completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            var request = "SET TEXTSIZE 2147483647 SELECT \(columnName) FROM \(tableSchema).\(tableName) WHERE "
            request += self.getWhereStatement(keyValue: dataModel)
            self.sqlClient.execute(request) { data in
                guard let data = data?.first as? NSArray else { completion(nil); return }
                guard let hexImageString = (data.firstObject as? NSDictionary)?.allValues.first as? String else { completion(nil); return }
                guard let imageData = Data(base64Encoded: hexImageString, options: .ignoreUnknownCharacters) else { completion(nil); return }
                guard let image = UIImage(data: imageData) else { completion(nil); return }
                completion(image)
            }
        }
    }
    
    public func createPDF() -> Data {
        guard let data = tableData.value else { return createFlyer() }
        guard let headers = tableHeaders.value else { return createFlyer() }
        let pdfCreator = PDFCreator(tableDataItems: data, tableDataHeaderTitles: headers)
        return pdfCreator.create()
    }
    
    private func createFlyer() -> Data {
        
        let pdfMetaData = [
            kCGPDFContextCreator: "SQLManager",
            kCGPDFContextAuthor: "user"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            
            context.beginPage()
            
            let attributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 72)
            ]
            let text = "I'm a PDF!"
            text.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        }
        
        return data
    }
    
    public func clearAllData() {
        UserDefaults.resetDefaults()
        sqlClient.disconnect()
        
        tableData.value = [[String]]()
        tableHeaders.value = [String]()
        notIdentityColumnsWithDataType.value = [ColumnDataTypeModel]()
    }
    
    public func changeTable(tableSchema: String, tableName: String) {
        UserDefaults.standard.tableSchema = tableSchema
        UserDefaults.standard.tableName = tableName
        
        fetchTableData()
        getColumnTypes()
    }
}

// MARK: - Get Methods
extension ViewModel {
    
    public func getColumnTypes(tableName: String = UserDefaults.standard.tableName ?? "",
                               tableSchema: String = UserDefaults.standard.tableSchema ?? "") {
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
    
    private func getWhereStatement(keyValue: [String: String]) -> String {
        var dict = keyValue
        
        var request = ""
        
        keyValue.forEach { (key, value) in
            if value.contains("xml") {
                dict.removeValue(forKey: key)
            } else if value == "<null>" {
                dict.removeValue(forKey: key)
            }
        }
        
        guard let values = notIdentityColumnsWithDataType.value else { return "" }
        values.forEach { model in
            if model.dataType == "text" {
                dict.removeValue(forKey: model.name)
            }
        }
        
        dict.forEach { (key, value) in
            request += "\(key) = \'\(value)\' and "
        }
        if request.last == " " {
            for _ in 0...3 {
                request.removeLast()
            }
        }
        
        return request
    }
}
