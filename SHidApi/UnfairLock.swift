import Foundation

public final class UnfairLock: SafeLocking {
    private let unfairLock: UnsafeMutablePointer<os_unfair_lock> = {
        let pointer = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        pointer.initialize(to: os_unfair_lock())
        return pointer
    }()

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    public func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    public func tryLock() -> Bool {
        os_unfair_lock_trylock(unfairLock)
    }

    public func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }

  public func `try`() -> Bool {
    os_unfair_lock_trylock(unfairLock)
  }

  public func lock(before limit: Date) -> Bool {
    assertionFailure("Unsupported in unfair lock")
    lock()
    return true
  }
}

typealias UnfairLocked<Value> = Locked<Value, UnfairLock>
