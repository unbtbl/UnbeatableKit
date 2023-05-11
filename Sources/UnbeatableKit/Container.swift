import Foundation
import SwiftUI

/// 🎁 A dependency injection container.
/// Dependencies can be registered using the subscript of the container.
/// To resolve dependencies, consider using `@Injected`.
/// In SwiftUI views, `@InjectedObject` can be used, which functions similar to `@EnvironmentObject`.
public struct Container {
    // MARK: - State
    
    /// The top-level dependency injection container.
    public static var global = Container()
    
    /// The current dependency injection container. This is the container that should be resolved against.
    public static var current: Container {
        local ?? global
    }
    
    /// The task local dependency injection container, if present. This is created using the `with` method.
    @TaskLocal
    private static var local: Container?
    
    /// The registered components.
    private var components = [ObjectIdentifier: Any]()
    
    /// Create a new dependency injection container.
    public init() {}
    
    /// Register or get a component.
    public subscript<T>(type: T.Type) -> T? {
        get {
            let key = ObjectIdentifier(type)
            return components[key] as? T
        }
        set {
            let key = ObjectIdentifier(type)
            components[key] = newValue
        }
    }
    
    /// Resolve the component `T`.
    /// - Precondition: A component of type `T` must be registered.
    public func resolve<T>(_ type: T.Type = T.self) -> T {
        guard let value = Container.current[T.self] else {
            preconditionFailure("No value for \(T.self) in container")
        }
        
        return value
    }
    
    // MARK: ❗️ Task local overrides
    
    /// Mutate a copy of the `current` container using `mutation`, then perform the given `action` with the mutated container as the `current` container.
    @discardableResult
    public static func with<R>(container mutation: (inout Container) throws -> Void, perform action: () throws -> R) rethrows -> R {
        var container = current
        try mutation(&container)
        return try Container.$local.withValue(container, operation: action)
    }
    
    /// Mutate a copy of the `current` container using `mutation`, then perform the given `action` with the mutated container as the `current` container.
    @discardableResult
    public static func with<R>(container mutation: (inout Container) async throws -> Void, perform action: () async throws -> R) async rethrows -> R {
        var container = current
        try await mutation(&container)
        return try await Container.$local.withValue(container, operation: action)
    }
}

@propertyWrapper
public struct Injected<Value> {
    public var wrappedValue: Value = Container.current.resolve()
    
    public init() {}
}

@propertyWrapper
public struct LazyInjected<Value> {
    public var wrappedValue: Value { Container.current.resolve() }
    
    public init() {}
}

@propertyWrapper
public struct InjectedObject<Value>: DynamicProperty where Value: ObservableObject {
    @ObservedObject
    public var wrappedValue: Value
    
    public var projectedValue: ObservedObject<Value>.Wrapper {
        $wrappedValue
    }
    
    public init() {
        let value: Value = Container.current.resolve()
        wrappedValue = value
    }
}
