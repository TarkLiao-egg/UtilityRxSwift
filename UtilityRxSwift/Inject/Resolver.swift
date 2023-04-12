import Foundation

class Resolver {

    static let shareInstance = Resolver()
    private var factories = [String: Any]()

    func setupFactories() {
        self.factories = [String: Any]()
        self.add(type: APIManager.self, APIManager.sharedInstance)
        self.add(type: FMDBManager.self, FMDBManager.sharedInstance)
        self.add(type: CoreDataManager.self, CoreDataManager.sharedInstance)
    }

    func add<T>(type: T.Type, _ factory: T) {
        let key = String(describing: T.self)
        factories[key] = factory
    }

    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: T.self)
        guard let component: T = factories[key] as? T else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }
        return component
    }
    
    static func getManager() -> CRUD {
        return Resolver.shareInstance.resolve(FMDBManager.self)
    }
}
