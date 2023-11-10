import Foundation

actor HidApiExecutor {
  struct Command: Sendable {
    private let block: @Sendable () throws -> Void
    private let completion: @Sendable (Result<Void, Error>) -> Void

    init(
      _ block: @Sendable @escaping () throws -> Void,
      completion: @Sendable @escaping (Result<Void, Error>) -> Void
    ) {
      self.block = block
      self.completion = completion
    }

    func callAsFunction() {
      do {
        try block()
        completion(.success(()))
      }
      catch {
        completion(.failure(error))
      }
    }
  }

  private let thread: Thread
  private let killed: UnfairLocked<Bool>
  private let openGate: DispatchSemaphore
  private let commands: UnfairLocked<[Command]>

  init() {
    let killed = UnfairLocked(false, lock: .init())
    let openGate: DispatchSemaphore = .init(value: 0)
    let commands: UnfairLocked<[Command]> = .init([], lock: .init())

    self.thread = .init(block: {
      while(!killed.read(\.self)) {
        openGate.wait()        
        guard let command = commands.mutate({ $0.popLast() }) else {
          continue
        }
        command()
      }
    })
    self.killed = killed
    self.openGate = openGate
    self.commands = commands
    thread.name = "HidApiExecutor"
    thread.start()
  }

  deinit {
    killed.mutate { $0 = true }
    openGate.signal()
  }

  func execute(_ command: @escaping @Sendable () throws -> Void) async throws {
    try await withCheckedThrowingContinuation { continuation in
      commands.mutate {
        let command = Command(command) { result in
          continuation.resume(with: result)
        }
        $0.append(command)
      }
      openGate.signal()
    }
  }
}
