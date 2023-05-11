import SwiftUI

public extension View {
    func task<T>(tracking: Binding<TaskState<T, Never>?>, priority: TaskPriority = .userInitiated, _ action: @escaping () async -> T) -> some View {
        task(priority: priority) {
            tracking.wrappedValue = .inProgress
            tracking.wrappedValue = .finished(.success(await action()))
        }
    }
    
    func task<T>(tracking: Binding<TaskState<T, Error>?>, priority: TaskPriority = .userInitiated, action: @escaping () async throws -> T) -> some View {
        task(priority: priority) {
            tracking.wrappedValue = .inProgress
            do {
                tracking.wrappedValue = .success(try await action())
            } catch {
                tracking.wrappedValue = .failure(error)
            }
        }
    }
    
    func task<T, ID>(tracking: Binding<TaskState<T, Never>?>, id: ID, priority: TaskPriority = .userInitiated, _ action: @escaping () async -> T) -> some View where ID: Equatable {
        task(id: id, priority: priority) {
            tracking.wrappedValue = .inProgress
            tracking.wrappedValue = .finished(.success(await action()))
        }
    }
    
    func task<T, ID>(tracking: Binding<TaskState<T, Error>?>, id: ID, priority: TaskPriority = .userInitiated, action: @escaping () async throws -> T) -> some View where ID: Equatable {
        task(id: id, priority: priority) {
            tracking.wrappedValue = .inProgress
            do {
                tracking.wrappedValue = .success(try await action())
            } catch {
                tracking.wrappedValue = .failure(error)
            }
        }
    }
}
