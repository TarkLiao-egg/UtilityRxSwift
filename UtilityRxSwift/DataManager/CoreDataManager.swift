import Foundation
import RxSwift
import CoreData

class CoreDataManager: NSObject, CRUD, NSFetchedResultsControllerDelegate {
    
    static let sharedInstance: CoreDataManager = .init()
    lazy var context: NSManagedObjectContext = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { storeDescription, error in
            print(storeDescription)
            if let error = error as NSError? {
                fatalError("error \(error), \(error.userInfo)")
            }
        }
        return container.viewContext
    }()
    var transactions = [TransactionCDB]()
    var fetchResultController: NSFetchedResultsController<TransactionCDB>!
    var transactionsCount = 0
    var transactionsDetailCount = 0
    
    func getTransactions() -> Single<[Transaction]> {
        let fetchRequestUpdate = NSFetchRequest<TransactionCDB>(entityName: "TransactionDetailCDB")
        do {
            let deletes = try context.fetch(fetchRequestUpdate)
            print("count:\(deletes.count)")
        } catch let fetchError{
            print("Failed to fetch compaies: \(fetchError)")
        }
        
        let fetchRequest: NSFetchRequest<TransactionCDB> = TransactionCDB.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
//        條件搜尋符合的第一筆
//        fetchRequest.fetchLimit = 1
//        fetchRequest.predicate = NSPredicate(format: "date == %@", "2020-9-28")
        
        var transactions = [Transaction]()
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
            if let object = fetchResultController.fetchedObjects {
                self.transactions = object
                transactionsCount = object.count
                transactions = object.map { item in
                    var data = Transaction(id: Int(item.id), time: Int(item.time?.timeIntervalSince1970 ?? 0), title: item.title ?? "", description: item.descriptionStr ?? "")
                    if let sets = item.details {
                        let array = sets.compactMap { item -> TransactionDetail? in
                            guard let cdb = item as? TransactionDetailCDB, let name = cdb.name else { return nil }
                            
                            return TransactionDetail(id: "\(Int(cdb.id))", name: name, quantity: Int(cdb.quantity), price: Int(cdb.quantity))
                        }
                        data.details = array
                    }
                    return data
                }
            }
        } catch {
            print(error)
        }
        return Single.just(transactions)
    }
    
    func postTransactions(param: TransactionPost) -> Single<[Transaction]> {
        let post = NSEntityDescription.insertNewObject(forEntityName: "TransactionCDB", into: context) as! TransactionCDB
        post.id = Int64(transactionsCount)
        transactionsCount += 1
        post.title = param.title
        post.time = Date(timeIntervalSince1970: TimeInterval(param.time))
        post.descriptionStr = param.description
        var details = [TransactionDetailCDB]()
        for item in param.details {
            let detail = NSEntityDescription.insertNewObject(forEntityName: "TransactionDetailCDB", into: context) as! TransactionDetailCDB
            detail.id = Int64(transactionsDetailCount)
            detail.price = Int64(item.price)
            detail.quantity = Int64(item.quantity)
            detail.name = item.name
            details.append(detail)
            transactionsDetailCount += 1
        }
        
        post.details = NSSet(array: details)
        saveContext()
        return getTransactions()
    }
    
    func putTransactions(id: Int, param: TransactionPost) -> Single<[Transaction]> {
        let fetchRequestUpdate = NSFetchRequest<TransactionCDB>(entityName: "TransactionCDB")
        fetchRequestUpdate.fetchLimit = 1
        fetchRequestUpdate.predicate = NSPredicate(format: "id == \(id)")
        
        var dic = [String: String]()
        for detail in param.details {
            dic[detail.id] = detail.name
        }
        do {
            let updates = try context.fetch(fetchRequestUpdate)
            if let update = updates[safe: 0] {
                update.descriptionStr = param.description
                guard let sets = update.details else  {
                    saveContext()
                    return getTransactions()
                }
                for detail in sets {
                    if let detail = detail as? TransactionDetailCDB {
                        detail.name = dic[String(detail.id)]
                    }
                }
            }
            saveContext()
        } catch let fetchError{
            print("Failed to fetch compaies: \(fetchError)")
        }
        return getTransactions()
    }
    
    func deleteTransactions(id: Int) -> Single<[Transaction]> {
        let fetchRequestDelete = NSFetchRequest<TransactionCDB>(entityName: "TransactionCDB")
        fetchRequestDelete.fetchLimit = 1
        fetchRequestDelete.predicate = NSPredicate(format: "id == \(id)")
        do {
            let deletes = try context.fetch(fetchRequestDelete)
            if let delete = deletes[safe: 0] {
                // relationship 設定cascade，可以一起刪除
                // https://www.jianshu.com/p/5ddde790c8b7
                
//                if let details = delete.details {
//                    for detail in details {
//                        if let detail = detail as? TransactionDetailCDB {
//                            context.delete(detail)
//                        }
//                    }
//                }
                context.delete(delete)
            }
        } catch let fetchError{
            print("Failed to fetch compaies: \(fetchError)")
        }
        
        return getTransactions()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("error \(error), \(error.userInfo)")
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}
