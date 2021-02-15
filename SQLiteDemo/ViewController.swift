//
//  ViewController.swift
//  SQLiteDemo
//
//  Created by Trista on 2021/2/14.
//

import UIKit
import SQLite3


class ViewController: UIViewController {

    //宣告一個變數儲存 SQLite 的連線資訊
    var db:OpaquePointer?
    //宣告一個變數statement取得操作資料庫後回傳的資訊
    var statement :OpaquePointer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //取得資料庫檔案的路徑
        //取得應用程式的 Documents 目錄--開放給開發者儲存檔案的路徑，有任何需要儲存的檔案都是放在這裡
        //sqlite3.db是這個資料庫檔案名稱，也可以命名為db.sqlite之類，其他可供辨識的檔案名稱。如果沒有這個檔案，系統會自動嘗試建立起來
        
        let sqliteURL = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask)
        let sqlitePath = sqliteURL[sqliteURL.count-1].absoluteString
                        + "sqlite3.db"
        /*
        let sqliteURL: URL = {
            do {
                return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("db.sqlite")
            }
            catch {
                fatalError("Error getting file URL from document directory.")
            }
        }()
        let sqlitePath = sqliteURL.path
        */
        //印出儲存檔案的位置
        print("sqlite檔案的路徑：",sqlitePath)
        
        
        //使用sqlite3_open()函式開啟資料庫連線
        //第二個參數也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數,前必須加上&，這是一個指標的概念(與輸入輸出參數 In-Out Parameters類似)，函式內使用的就是傳入參數db本身，操作資料庫時可以直接使用這個db變數
        if sqlite3_open(sqlitePath, &db) == SQLITE_OK {
            print("資料庫連線成功")
        } else {
            print("資料庫連線失敗")
        }
        
        //建立資料表
        //建立一個名為 students 的資料表，欄位分別為 id, name, height ，欄位類型依序為 integer, text, double
        var sql = "create table if not exists students "
                + "( id integer primary key autoincrement, "
                + "name text, height double)" as NSString

        //使用sqlite3_exec()函式建立資料表
        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。
        //如果返回為SQLITE_OK，則表示建立成功
        if sqlite3_exec(db, sql.utf8String, nil, nil, nil)
          == SQLITE_OK{
            print("建立資料表成功")
        }
        
        
        //使用sqlite3_prepare_v2()函式新增資料
        sql = "insert into students "
                + "(name, height) "
                + "values ('王大明', 175.3)" as NSString
        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。如果返回為SQLITE_OK，則表示建立成功
        //第三個參數則是設定資料庫可以讀取的最大資料量，單位是位元組(Byte)，設為-1表示不限制讀取量
        //第四個參數，也是宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，參數前面要加上&
        if sqlite3_prepare_v2(
            db, sql.utf8String, -1, &statement, nil) == SQLITE_OK{
            
            //宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數,要再當做sqlite3_step()函式的參數傳入
            //返回SQLITE_DONE，則是表示新增資料成功
            if sqlite3_step(statement) == SQLITE_DONE {
                print("新增資料成功")
            }
            //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
            sqlite3_finalize(statement)
        }
        
        
        //使用sqlite3_prepare_v2()函式讀取資料
        sql = "select * from students"
        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。如果返回為SQLITE_OK，則表示建立成功
        //第三個參數則是設定資料庫可以讀取的最大資料量，單位是位元組(Byte)，設為-1表示不限制讀取量
        //第四個參數，也是宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，參數前面要加上&
        sqlite3_prepare_v2(
            db, (sql as NSString).utf8String, -1, &statement, nil)

        //回傳的資料存在，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數中，以while迴圈來一筆一筆取出，當等於SQLITE_ROW時就是有資料，會一直取到不為SQLITE_ROW，就會結束迴圈。(如果只有一筆資料的話，也可以使用if條件句即可。)
        while sqlite3_step(statement) == SQLITE_ROW{
            
            //使用sqlite3_column_資料類型()函式來取出迴圈中每筆資料的每個欄位，像是 int 的欄位就是使用sqlite3_column_int()， text 的欄位就是使用sqlite3_column_text()， double 的欄位就是使用sqlite3_column_double()，以此類推。
            //取出欄位的函式有兩個參數
            //第一個都固定是，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數
            //第二個是這個欄位的索引值，範例有三個欄位： id, name, height ，則索引值從 0 開始算起，依序為 0, 1, 2 。
            let id = sqlite3_column_int(statement, 0)
            let name = String(cString: sqlite3_column_text(statement, 1))
            let height = sqlite3_column_double(statement, 2)
            print("\(id). \(name) 身高： \(height)")
        }
        //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
        sqlite3_finalize(statement)
        
        
        //使用sqlite3_prepare_v2()函式更新資料
        sql = "update students set name='李夢夢',height=162.5 where id = 2"

        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。如果返回為SQLITE_OK，則表示建立成功
        //第三個參數則是設定資料庫可以讀取的最大資料量，單位是位元組(Byte)，設為-1表示不限制讀取量
        //第四個參數，也是宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，參數前面要加上&
        if sqlite3_prepare_v2(
            db, (sql as NSString).utf8String, -1, &statement, nil)
          == SQLITE_OK {
            
            //宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數,要再當做sqlite3_step()函式的參數傳入
            //返回SQLITE_DONE，則是表示更新資料成功
            if sqlite3_step(statement) == SQLITE_DONE {
                print("更新資料成功")
            }
            
            //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
            sqlite3_finalize(statement)
        }
        
        
        //使用sqlite3_prepare_v2()函式讀取資料
        sql = "select * from students"
        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。如果返回為SQLITE_OK，則表示建立成功
        //第三個參數則是設定資料庫可以讀取的最大資料量，單位是位元組(Byte)，設為-1表示不限制讀取量
        //第四個參數，也是宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，參數前面要加上&
        sqlite3_prepare_v2(
            db, (sql as NSString).utf8String, -1, &statement, nil)

        //回傳的資料存在，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數中，以while迴圈來一筆一筆取出，當等於SQLITE_ROW時就是有資料，會一直取到不為SQLITE_ROW，就會結束迴圈。(如果只有一筆資料的話，也可以使用if條件句即可。)
        while sqlite3_step(statement) == SQLITE_ROW{
            
            //使用sqlite3_column_資料類型()函式來取出迴圈中每筆資料的每個欄位，像是 int 的欄位就是使用sqlite3_column_int()， text 的欄位就是使用sqlite3_column_text()， double 的欄位就是使用sqlite3_column_double()，以此類推。
            //取出欄位的函式有兩個參數
            //第一個都固定是，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數
            //第二個是這個欄位的索引值，範例有三個欄位： id, name, height ，則索引值從 0 開始算起，依序為 0, 1, 2 。
            let id = sqlite3_column_int(statement, 0)
            let name = String(cString: sqlite3_column_text(statement, 1))
            let height = sqlite3_column_double(statement, 2)
            print("\(id). \(name) 身高： \(height)")
        }
        //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
        sqlite3_finalize(statement)
        
        
        //使用sqlite3_prepare_v2()函式刪除資料
        sql = "delete from students where id = 5"

        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。如果返回為SQLITE_OK，則表示建立成功
        //第三個參數則是設定資料庫可以讀取的最大資料量，單位是位元組(Byte)，設為-1表示不限制讀取量
        //第四個參數，也是宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，參數前面要加上&
        if sqlite3_prepare_v2(
            db, (sql as NSString).utf8String, -1, &statement, nil)
          == SQLITE_OK {
            
            //宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數,要再當做sqlite3_step()函式的參數傳入
            //返回SQLITE_DONE，則是表示刪除資料成功
            if sqlite3_step(statement) == SQLITE_DONE {
                print("刪除資料成功")
            }
            //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
            sqlite3_finalize(statement)
        }
        
        
        //使用sqlite3_prepare_v2()函式讀取資料
        sql = "select * from students"
        //第一個參數就是建立資料庫連線的傳入參數，也是宣告儲存 SQLite 的連線資訊，型別為OpaquePointer的變數
        //第二個參數是 SQL 指令，會先轉成NSString型別，再將文字編碼轉成 UTF8。如果返回為SQLITE_OK，則表示建立成功
        //第三個參數則是設定資料庫可以讀取的最大資料量，單位是位元組(Byte)，設為-1表示不限制讀取量
        //第四個參數，也是宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，參數前面要加上&
        sqlite3_prepare_v2(
            db, (sql as NSString).utf8String, -1, &statement, nil)

        //回傳的資料存在，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數中，以while迴圈來一筆一筆取出，當等於SQLITE_ROW時就是有資料，會一直取到不為SQLITE_ROW，就會結束迴圈。(如果只有一筆資料的話，也可以使用if條件句即可。)
        while sqlite3_step(statement) == SQLITE_ROW{
            
            //使用sqlite3_column_資料類型()函式來取出迴圈中每筆資料的每個欄位，像是 int 的欄位就是使用sqlite3_column_int()， text 的欄位就是使用sqlite3_column_text()， double 的欄位就是使用sqlite3_column_double()，以此類推。
            //取出欄位的函式有兩個參數
            //第一個都固定是，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數
            //第二個是這個欄位的索引值，範例有三個欄位： id, name, height ，則索引值從 0 開始算起，依序為 0, 1, 2 。
            let id = sqlite3_column_int(statement, 0)
            let name = String(cString: sqlite3_column_text(statement, 1))
            let height = sqlite3_column_double(statement, 2)
            print("\(id). \(name) 身高： \(height)")
        }
        //使用sqlite3_finalize()函式釋放掉，宣告取得操作資料庫後回傳的資訊，型別為OpaquePointer的變數，以免發生記憶體洩漏的問題
        sqlite3_finalize(statement)
        
    }

}

