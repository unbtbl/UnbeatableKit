import SwiftUI
import Combine

extension Task {
    public typealias State = TaskState<Success, Failure>
    
    @discardableResult
    public init(
        tracking binding: Binding<State?>,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async -> Success
    ) where Failure == Never {
        self.init(priority: priority) { @MainActor in
            binding.wrappedValue = .inProgress
            let result = await operation()
            binding.wrappedValue = .finished(.success(result))
            return result
        }
    }

    @discardableResult
    public init(
        tracking binding: Binding<State?>,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success
    ) where Failure == Error {
        self.init(priority: priority) { @MainActor in
            binding.wrappedValue = .inProgress
            do {
                let result = try await operation()
                binding.wrappedValue = .finished(.success(result))
                return result
            } catch {
                binding.wrappedValue = .finished(.failure(error))
                throw error
            }
        }
    }
    
    @discardableResult
    public init(
        tracking published: inout Published<State?>.Publisher,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async -> Success
    ) where Failure == Never {
        let subject = PassthroughSubject<State?, Never>()
        
        subject
            .receive(on: DispatchQueue.main)
            .assign(to: &published)
        
        self.init(priority: priority) {
            subject.send(.inProgress)
            let result = await operation()
            subject.send(.finished(.success(result)))
            subject.send(completion: .finished)
            return result
        }
    }
    
    @discardableResult
    public init(
        tracking published: inout Published<State?>.Publisher,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success
    ) where Failure == Error {
        let subject = PassthroughSubject<State?, Never>()
        
        subject
            .receive(on: DispatchQueue.main)
            .assign(to: &published)
        
        self.init(priority: priority) {
            subject.send(.inProgress)
            do {
                let result = try await operation()
                subject.send(.finished(.success(result)))
                subject.send(completion: .finished)
                return result
            } catch {
                subject.send(.finished(.failure(error)))
                subject.send(completion: .finished)
                throw error
            }
        }
    }

    // MARK: - Apply, Throwing
    
    public static func apply(
        _ tracking: Binding<State?>,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success
    ) -> (() -> Void) where Failure == Error {
        {
            Task(tracking: tracking) {
                try await operation()
            }
        }
    }
    
    public static func apply<A1>(
        _ tracking: Binding<State?>,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable (A1) async throws -> Success
    ) -> ((A1) -> Void) where Failure == Error {
        { arg1 in
            Task(tracking: tracking) {
                try await operation(arg1)
            }
        }
    }
    
    // MARK: - Apply, Non-Throwing
    
    public static func apply(
        _ tracking: Binding<State?>,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async -> Success
    ) -> (() -> Void) where Failure == Never {
        {
            Task(tracking: tracking) {
                await operation()
            }
        }
    }
    
    public static func apply<A1>(
        _ tracking: Binding<State?>,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable (A1) async -> Success
    ) -> ((A1) -> Void) where Failure == Never {
        { arg1 in
            Task(tracking: tracking) {
                await operation(arg1)
            }
        }
    }

}
