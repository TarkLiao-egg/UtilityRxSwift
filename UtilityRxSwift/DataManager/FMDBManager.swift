import Foundation
import FMDB
import RxSwift
protocol CRUD {
    func getTransactions() -> Single<[Transaction]>
    func postTransactions(param: TransactionPost) -> Single<[Transaction]>
    func putTransactions(id: Int, param: TransactionPost) -> Single<[Transaction]>
    func deleteTransactions(id: Int) -> Single<[Transaction]>
}

class FMDBManager: CRUD {
    static let sharedInstance:FMDBManager = .init()
    static let dbName = "transaction.db"
    lazy var dbURL: URL = {
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask,
                 appropriateFor: nil, create: true)
            .appendingPathComponent(FMDBManager.dbName)
        print(fileURL)
        return fileURL
    }()
    
    lazy var db: FMDatabase = {
        let database = FMDatabase(url: dbURL)
        return database
    }()
    
    func getTransactions() -> Single<[Transaction]> {
        var transactions = TransactionDB.rows().map { item in
            return Transaction(id: item.id, time: item.time, title: item.title, description: item.descriptionStr)
        }
        let transactionDetailsDB = TransactionDetailDB.rows()
        
        for (index, _) in transactions.enumerated() {
            for detail in transactionDetailsDB {
                if detail.transaction_id == transactions[index].id {
                    transactions[index].details?.append(TransactionDetail(name: detail.name, quantity: detail.quantity, price: detail.price))
                }
            }
        }
        return Single<[Transaction]>.just(transactions)
    }
    
    func postTransactions(param: TransactionPost) -> Single<[Transaction]> {
        let post = TransactionDB(time: param.time, title: param.title, description: param.description)
        post.save()
        let count = TransactionDB.latestIndex()
        for detail in param.details {
            let post = TransactionDetailDB(name: detail.name, quantity: detail.quantity, price: detail.price, transaction_id: count)
            post.save()
        }
        return getTransactions()
    }
    
    func putTransactions(id: Int, param: TransactionPost) -> Single<[Transaction]> {
        let put = TransactionDB(time: param.time, title: param.title, description: param.description)
        put.id = id
        put.save()
        let details = TransactionDetailDB.rows(filter: "transaction_id = \(id)")
        for detail in details {
            detail.delete()
        }
        for detail in param.details {
            let post = TransactionDetailDB(name: detail.name, quantity: detail.quantity, price: detail.price, transaction_id: id)
            post.save()
        }
        return getTransactions()
    }
    
    func deleteTransactions(id: Int) -> Single<[Transaction]> {
        let details = TransactionDetailDB.rows(filter: "transaction_id = \(id)")
        for detail in details {
            detail.delete()
        }
        let transaction = TransactionDB()
        transaction.id = id
        transaction.delete()
        return getTransactions()
    }
}
