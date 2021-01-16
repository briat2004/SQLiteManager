//
//  SqliteManager.swift
//  SQLiteManager
//
//  Created by BruceWu on 2020/11/7.
//

import Foundation
import SQLite3

public class SqliteManager {
    
    public typealias Success = () -> ()
    public typealias Failure = () -> ()
    public typealias SuccessByOpaquePointer = (OpaquePointer?) -> ()
    //儲存 SQLite 的連線資訊
    private var db: OpaquePointer? = nil
    
    /// add new sqlite db
    /// - Parameters:
    ///   - dbName: If parameter dbName is not exists, then create one.
    /// - Returns: nil
    public init(dbName: String, success: Success, failure: Failure) {
        //        存檔路徑
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //        新增sqlite3.db檔
        let sqlitePath = urls[urls.count - 1].absoluteString + dbName
        print("dbPath: \(sqlitePath)")
        //開啟資料庫連線
        if sqlite3_open(sqlitePath, &db) == SQLITE_OK {
            success()
            //            資料庫連線成功
        } else {
            failure()
            //            資料庫連線失敗
        }
    }
    
    //建立table
    /// CREATE TABLE IF NOT EXISTS tableName (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, AGE DOUBLE, HEIGHT DOUBLE)
    /// Ex: ["NAME TEXT", "AGE DOUBLE", "HEIGHT DOUBLE"]
    /// - Parameters:
    ///   - tableName: If parameter tableName is not exists, then create one
    ///   - columns: Add your fields input dictionary in array.
    /// - Returns: nil
    public func createTable(tableName: String, columns: [String], success: Success? = nil, failure: Failure? = nil) {
        let sql = CREATE_TABLE_IF_NOT_EXISTS + tableName + "( ID INTEGER PRIMARY KEY AUTOINCREMENT, " + columns.joined(separator: ",") + ")" as NSString
        if sqlite3_exec(db, sql.utf8String, nil, nil, nil) == SQLITE_OK {
            if let success = success {
                success()
            }
        } else {
            if let failure = failure {
                failure()
            }
        }
    }
    
    //插入資料
    /// Insert data
    /// EX: INSERT INTO tableName (NAME, AGE, HEIGHT) VALUES ('Bruce', 18, 173)
    /// - Parameters:
    ///   - tableName: your table name
    ///   - rows: ["NAME": "'Bruce'", "AGE": "18", "HEIGHT": "173"]
    public func insert(tableName: String, rows: [String: String], success: Success? = nil, failure: Failure? = nil) {
        var statement: OpaquePointer? = nil
        let sql = INSERT_INTO + tableName + " (\(rows.keys.joined(separator: ",")))" + " VALUES " + "(\(rows.values.joined(separator: ",")))" as NSString
        if sqlite3_prepare_v2(db, sql.utf8String, -1, &statement, nil) == SQLITE_OK {
            //SQLITE_DONE 新增成功
            if sqlite3_step(statement) == SQLITE_DONE {
                if let success = success {
                    success()
                }
            } else {
                if let failure = failure {
                    failure()
                }
            }
        }
        sqlite3_finalize(statement)
    }
    
    /// select table insert condition to search column
    /// EX: SELECT * FROM tableName WHERE "NAME == 'Value'" ORDER BY AGE
    /// - Parameters:
    ///   - tableName: your table name
    ///   - whereBy: select you want. EX: "NAME == 'Sarah'" or "NUMBER == 1"
    ///   - order: according to the arrangement EX: AGE
    public func select(tableName: String, whereBy: String?, order: String? , success: SuccessByOpaquePointer? = nil, failure: Failure? = nil) {
        var statement: OpaquePointer? = nil
        var sql = "SELECT * FROM \(tableName)"
        if let whereBy = whereBy {
            let wh = " WHERE \(whereBy)"
            sql += wh
        }
        if let order = order {
            let od = " order by \(order)"
            sql += od
        }
        let sqlCmd = sql as NSString
        if sqlite3_prepare_v2(db, sqlCmd.utf8String, -1, &statement, nil) == SQLITE_OK {
            if let success = success {
                success(statement)
            }
        }else {
            if let failure = failure {
                failure()
            }
        }
    }
    
    /// update
    /// EX: UPDATE tableName SET NAME = 'Bruce', AGE = 28 WHERE ID = 1
    /// - Parameters:
    ///   - tableName: your table name
    ///   - condition: "ID = 1"
    ///   - row: EX: ["NAME": "'Sarah'"]
    public func update(tableName: String, condition: String?, row: [String: String]?, success: Success? = nil, failure: Failure? = nil) {
        var statement: OpaquePointer? = nil
        var sql = "UPDATE \(tableName) SET "
        var arr = [String]()
        if let row = row {
            for (key, val) in row {
                arr.append("\(key) = \(val)")
            }
            sql += arr.joined(separator: ",")
        }
        if let condition = condition {
            sql += " WHERE \(condition)"
        }
        if sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                if let success = success {
                    success()
                }
            }else {
                if let failure = failure {
                    failure()
                }
            }
            sqlite3_finalize(statement)
        }
    }
    
    /// delete you select condition
    /// EX: DELETE FROM tableName WHERE ID = 1
    /// - Parameters:
    ///   - tableName: your table name
    ///   - contition: "ID = 1"
    public func delete(tableName: String, contition: String?, success: Success? = nil, failure: Failure? = nil) {
        var statement: OpaquePointer? = nil
        var sql = "DELETE FROM \(tableName) "
        if let contition = contition {
            let wh = "WHERE \(contition)"
            sql += wh
        }
        if sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                if let success = success {
                    success()
                }
            } else {
                if let failure = failure {
                    failure()
                }
            }
        }
    }
}

