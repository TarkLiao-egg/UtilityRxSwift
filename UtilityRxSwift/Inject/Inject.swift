import Foundation

@propertyWrapper
public struct Inject<T> {

    public var wrappedValue: T {
        Resolver.shareInstance.resolve(T.self)
    }

    public init() {}
}
