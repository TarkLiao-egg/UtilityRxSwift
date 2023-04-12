import UIKit
import RxSwift
import RxCocoa
import Combine

import Foundation


class FMDBController: UIViewController {
    var disposeBag: DisposeBag = .init()
    
    @Inject private var apiManager: APIManager
    @Inject private var dbManager: FMDBManager
//    var data = DataDB()
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
//        data = DataDB(title: "test", image: UIImage(named: "default")!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = .init()
    }
}

extension FMDBController {
    //final @objc：呼叫函式時會使用直接派發，但也會在 Objective-C 執行時中註冊響應的 selector 。函式可以響應 perform(seletor:) 以及別的 Objective-C 特性，但在直接呼叫時又可以具有直接派發的效能。
    @objc final private func getTableViewData() {
        getTransactionListViewObjects(1) {
            
        }
    }
}

extension FMDBController {
    func getTransactionListViewObjects(_ i:Int, completion: (()-> ())? = nil) {
//        dbManager.getTransactions()
        Resolver.getManager().getTransactions()
//            .map(TransactionListViewModel.mapTransactionListViewObject)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] (contracts) in
                completion?()
            }) { [unowned self] (error) in
                completion?()
            }.disposed(by: self.disposeBag)
    }
    
    func deleteTransactionListViewObjects(id: Int, disposeBag: DisposeBag) {
        Resolver.getManager().deleteTransactions(id: id)
//            .map(TransactionListViewModel.mapTransactionListViewObject)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] (contracts) in
            }) { [unowned self] (error) in
                
            }.disposed(by: self.disposeBag)
    }
    
//    static func mapTransactionListViewObject(_ transform: ([Transaction])) -> TransactionListViewObject {
//        let transactions = transform.sorted { t1, t2 in
//            return t1.time > t2.time
//        }
//        let sum = transactions.reduce(0) { partialResult, transaction in
//            guard let details = transaction.details else { return 0 }
//            var total = 0
//            for detail in details {
//                total += detail.price * detail.quantity
//            }
//            return partialResult + total
//        }
//        return .init(sum: sum, sections: TransactionListViewModel.getSections(transactions: transactions))
//    }
}

extension FMDBController {
    func setupUI() {
        view.backgroundColor = .black
        
//        imageView = UIImageView.name("").VS({
//            $0.contentMode = .scaleToFill
//        }, view) { make in
//            make.size.equalTo(100)
//            make.center.equalToSuperview()
//        }
//        
//        UIButton().VS({
//            $0.setTitle("set", for: .normal)
//            $0.addTarget(self, action: #selector(self.imageSelector), for: .touchUpInside)
//        }, view) { make in
//            make.centerY.equalToSuperview()
//            make.leading.equalToSuperview()
//            make.size.equalTo(100)
//        }
    }
    
    @objc func imageSelector() {
//        imageView.image = UIImage(data: data.imageData as Data)
    }
}
