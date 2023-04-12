import Foundation
import Alamofire
import RxSwift

class APIManager: CRUD {

    private static let host:String = "https://e-app-testing-z.herokuapp.com"
    private static let transaction:String = "/transaction"

    static let sharedInstance:APIManager = .init()

    func getTransactions() -> Single<[Transaction]> {
        return get().flatMap { (data) -> Single<[Transaction]> in
            return APIManager.handleDecode([Transaction].self, from: data)
        }
    }
    
    func postTransactions(param: TransactionPost) -> Single<[Transaction]> {
        return post(param: param).flatMap { (data) -> Single<[Transaction]> in
            return APIManager.handleDecode([Transaction].self, from: data)
        }
    }
    
    func putTransactions(id: Int, param: TransactionPost) -> Single<[Transaction]> {
        return put(id: id, param: param).flatMap { (data) -> Single<[Transaction]> in
            return APIManager.handleDecode([Transaction].self, from: data)
        }
    }
    
    func deleteTransactions(id: Int) -> Single<[Transaction]> {
        return delete(id: id).flatMap { (data) -> Single<[Transaction]> in
            return APIManager.handleDecode([Transaction].self, from: data)
        }
    }
    
    public enum DecodeError: Error, LocalizedError {
        case dataNull
        public var errorDescription: String? {
            switch self {
            case .dataNull:
                return "Data Null"
            }
        }
    }

    private static func handleDecode<T>(_ type: T.Type, from data: Data?) -> Single<T> where T: Decodable {
        if let strongData = data {
            do {
                let toResponse = try JSONDecoder().decode(T.self ,from: strongData)
                return Single<T>.just(toResponse)
            } catch {
                return Single.error(error)
            }
        } else {
            return Single.error(DecodeError.dataNull)
        }
    }

    private func get() -> Single<Data?> {
        return Single<Data?>.create { (singleEvent) -> Disposable in
            Alamofire.SessionManager.default.request(APIManager.host + APIManager.transaction, method: .get).responseJSON { (response) in
                switch response.result {
                case .success:
                    if let jsonData = response.data , let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                       print("JSONString = " + JSONString)
                    }
                    singleEvent(.success(response.data))
                case .failure(let error):
                    singleEvent(.error(error))
                }
            }
            return Disposables.create()
        }
        
    }
    
    private func post(param: TransactionPost) -> Single<Data?> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(param), let dict = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) else {
            return Single.just(nil)
        }
        
        return Single<Data?>.create { (singleEvent) -> Disposable in
            Alamofire.SessionManager.default.request(APIManager.host + APIManager.transaction, method: .post, parameters: dict as? Parameters, encoding: JSONEncoding.default).responseJSON { (response) in
                switch response.result {
                case .success:
                    if let jsonData = response.data , let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                       print("JSONString = " + JSONString)
                    }
                    singleEvent(.success(response.data))
                case .failure(let error):
                    singleEvent(.error(error))
                }
            }
            return Disposables.create()
        }
    }
    
    private func put(id: Int, param: TransactionPost) -> Single<Data?> {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(param), let dict = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) else {
            return Single.just(nil)
        }
        return Single<Data?>.create { (singleEvent) -> Disposable in
            Alamofire.SessionManager.default.request(APIManager.host + APIManager.transaction + "/\(id)", method: .put, parameters: dict as? Parameters, encoding: JSONEncoding.default).responseJSON { (response) in
                switch response.result {
                case .success:
                    if let jsonData = response.data , let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                        print("JSONString = " + JSONString)
                        
                    }
                    singleEvent(.success(response.data))
                case .failure(let error):
                    singleEvent(.error(error))
                }
            }
            return Disposables.create()
        }
    }
    
    private func delete(id: Int) -> Single<Data?> {
        return Single<Data?>.create { (singleEvent) -> Disposable in
            Alamofire.SessionManager.default.request(APIManager.host + APIManager.transaction + "/\(id)", method: .delete).responseJSON { (response) in
                switch response.result {
                case .success:
                    if let jsonData = response.data , let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                       print("JSONString = " + JSONString)
                    }
                    singleEvent(.success(response.data))
                case .failure(let error):
                    singleEvent(.error(error))
                }
            }
            return Disposables.create()
        }
    }
}
