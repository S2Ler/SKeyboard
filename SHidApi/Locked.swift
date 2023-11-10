import Foundation

/// Describe an interface for lock implementation with a safe lock functions.
public protocol SafeLocking {
    func lock()
    func unlock()
    func `try`() -> Bool
    func lock(before limit: Date) -> Bool
}

public typealias NSLocked<Value> = Locked<Value, NSLock>

/// Wraps `Value` under `Lock`.
/// - Important: This type contains unsafe methods which you must use only when `Locked.init(_:lock:)` init is used and
///              the provided lock is locked. This is useful when you have a lot of atomic variables which you want to
///              modify protected by one lock.
public final class Locked<Value, Lock: SafeLocking>: @unchecked
Sendable {
    private let lock: Lock
    private var value: Value

    /// Creates a new locked value with initial value and protect with a given lock.
    /// - Parameters:
    ///   - wrappedValue: Initial value.
    ///   - lock: The lock that will be used to protect access to the wrappedValue.
    public init(_ wrappedValue: Value, lock: Lock) {
        self.value = wrappedValue
        self.lock = lock
    }

    /// Safely reads the protected value with the `protectedBlock` block.
    ///
    /// - Important: The lock is locked while `protectedBlock` is executing.
    /// - Returns: A value returned from `protectedBlock`.
    public func read<Output>(_ protectedBlock: (Value) throws -> Output) rethrows -> Output {
        try lock.withLock {
            try protectedBlock(value)
        }
    }

    /// Safely reads a key path references by `keyPath` from protected value.
    public func read<Output>(_ keyPath: KeyPath<Value, Output>) -> Output {
        lock.withLock { value[keyPath: keyPath] }
    }

    /// Safely mutates the protected value with the `mutation` block.
    ///
    /// - Returns: A value returned from the `mutation` block.
    public func mutate<Output>(_ mutation: (inout Value) throws -> Output) rethrows -> Output {
        try withLock(mutation)
    }

    /// Same as ``mutate(_:)`` but doesn't lock the lock during execution. It is the callers responsibility to make sure
    /// that the lock is locked.
    public func unsafeMutate<Output>(_ mutation: (inout Value) throws -> Output) rethrows -> Output {
        try mutation(&value)
    }

    /// Same as ``read(_:)-5qzcg`` but doesn't lock the lock during execution. It is the callers responsibility to make
    /// sure that the lock is locked.
    public func unsafeRead<Output>(_ protectedBlock: (Value) throws -> Output) rethrows -> Output {
        try protectedBlock(value)
    }

    /// Same as ``read(_:)-2k2dx`` but doesn't lock the lock during execution. It is the callers responsibility to make
    /// sure that the lock is locked.
    public func unsafeRead<Output>(_ keyPath: KeyPath<Value, Output>) -> Output {
        value[keyPath: keyPath]
    }

    private func withLock<Output>(_ block: (inout Value) throws -> Output) rethrows -> Output {
        lock.lock()
        defer {
            lock.unlock()
        }
        return try block(&value)
    }
}

extension NSLock: SafeLocking {}

extension SafeLocking {
    /// Executes `protectedBlock` in the locked state.
    ///
    /// - Returns: A value returned from the `protectedBlock` block.
    public func withLock<Output>(_ protectedBlock: () throws -> Output) rethrows -> Output {
        lock()
        defer {
            unlock()
        }
        return try protectedBlock()
    }
}

extension Locked where Lock == NSLock {
    /// Creates a new locked value protected by a new NSLock.
    public convenience init(_ wrappedValue: Value) {
        self.init(wrappedValue, lock: NSLock())
    }
}
