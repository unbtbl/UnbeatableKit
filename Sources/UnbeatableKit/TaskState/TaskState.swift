/// Describes the progress of an asynchronous task.
/// Alongside this type, various helpers are provided to make it easy to map asynchronous operations to the UI of an app.
public enum TaskState<Success, Failure>: _TaskState where Failure: Error {
    /// The task is in progress.
    case inProgress

    /// The task is finished.
    case finished(Result<Success, Failure>)

    static func success(_ value: Success) -> Self {
        return .finished(.success(value))
    }

    static func failure(_ error: Failure) -> Self {
        return .finished(.failure(error))
    }

    // MARK: Accessing the status of the task

    public var isInProgress: Bool {
        if case .inProgress = self {
            return true
        }

        return false
    }

    public var isFinished: Bool {
        if case .finished = self {
            return true
        }

        return false
    }

    public var isSuccessful: Bool {
        if case .finished(.success) = self {
            return true
        }

        return false
    }

    public var isFailure: Bool {
        if case .finished(.failure) = self {
            return true
        }

        return false
    }

    public var result: Result<Success, Failure>? {
        if case .finished(let result) = self {
            return result
        }

        return nil
    }

    public var success: Success? {
        if case .finished(.success(let success)) = self {
            return success
        }

        return nil
    }

    public var failure: Failure? {
        if case .finished(.failure(let failure)) = self {
            return failure
        }

        return nil
    }
}

/// This exists so we can extend Optional<TaskState> to provide some convenience methods.
public protocol _TaskState {
    associatedtype Success
    associatedtype Failure: Error

    static var inProgress: Self { get }
    static func finished(_ result: Result<Success, Failure>) -> Self

    var isInProgress: Bool { get }
    var isFinished: Bool { get }
    var isSuccessful: Bool { get }
    var isFailure: Bool { get }
    var result: Result<Success, Failure>? { get }
    var success: Success? { get }
    var failure: Failure? { get }
}

extension Optional where Wrapped: _TaskState {
    /// Returns true if the task is in progress.
    /// Setting this to `true` will set the task to in progress.
    /// Setting this to `false` will set the task to `nil` if it is in progress.
    public var isInProgress: Bool {
        get {
            return self?.isInProgress ?? false
        }
        set {
            if newValue {
                self = .inProgress
            } else if isInProgress {
                self = nil
            }
        }
    }
    
    public var isSuccessful: Bool {
        return self?.isSuccessful ?? false
    }
    
    public var isFailure: Bool {
        return self?.isFailure ?? false
    }
    
    public var isFinished: Bool {
        return self?.isFinished ?? false
    }

    /// Returns the error that caused the task to fail.
    /// Setting this to a non-nil value will set the task to finished with the given error.
    /// Setting this to `nil` will set the task to `nil` if it is finished with an error.
    public var failure: Wrapped.Failure? {
        get {
            return self?.failure
        }
        set {
            if let newValue = newValue {
                self = .finished(.failure(newValue))
            } else if failure != nil {
                self = nil
            }
        }
    }

    /// Returns the result of the task.
    /// Setting this to a non-nil value will set the task to finished with the given result.
    /// Setting this to `nil` will set the task to `nil` if it is finished.
    public var success: Wrapped.Success? {
        get {
            return self?.success
        }
        set {
            self = newValue.map { .finished(.success($0)) }
        }
    }
}

extension TaskState: Equatable where Success: Equatable, Failure: Equatable {}
extension TaskState: Hashable where Success: Hashable, Failure: Hashable {}
