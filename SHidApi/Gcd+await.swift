import Foundation

extension DispatchQueue {
  func async<T>(block: @Sendable @escaping () throws -> T) async throws -> T {
    try await withUnsafeThrowingContinuation { continuation in
      self.async {
        do {
          continuation.resume(returning: try block())
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
