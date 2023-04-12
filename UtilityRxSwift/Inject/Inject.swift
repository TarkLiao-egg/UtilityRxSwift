import Foundation

@propertyWrapper
public struct Inject<T> {

    public var wrappedValue: T {
        Resolver.shareInstance.resolve(T.self)
    }

    public init() {}
}


extension Array {
    subscript(safe index: Int) -> Element? {
        self.indices.contains(index) ? self[index] : nil
    }
}
