import SwiftUI

/// A property wrapper that can be either a `Binding` or a `State`.
@propertyWrapper
public enum BindingOrState<Value>: DynamicProperty {
    case binding(Binding<Value>)
    case state(State<Value>)
    
    public init(wrappedValue: Value) {
        self = .state(State(wrappedValue: wrappedValue))
    }

    public var wrappedValue: Value {
        get {
            switch self {
            case .binding(let binding):
                return binding.wrappedValue
            case .state(let state):
                return state.wrappedValue
            }
        }
        nonmutating set {
            switch self {
            case .binding(let binding):
                binding.wrappedValue = newValue
            case .state(let state):
                state.wrappedValue = newValue
            }
        }
    }
    
    public var projectedValue: Binding<Value> {
        switch self {
        case .binding(let binding):
            return binding
        case .state(let state):
            return state.projectedValue
        }
    }
}
