import CHidApi
import Foundation
@preconcurrency import OSLog

public enum HidApiError: LocalizedError {
  case initializationFailed(message: String)
  case enumerationFailed(message: String)
  case openDeviceFailed(message: String)
  case writeToDeviceFailed(message: String)
  case readTimeout(message: String)

  public var errorDescription: String? {
    switch self {
    case .initializationFailed(let message):
      return "HidApi initialization failed: \(message)"
    case .enumerationFailed(message: let message):
      return "HidApi enumeration failed: \(message)"
    case .openDeviceFailed(let message):
      return "HidApi open device failed: \(message)"
    case .writeToDeviceFailed(let message):
      return "HidApi write to device failed: \(message)"
    case .readTimeout(let message):
      return "HidApi read timeout: \(message)"
    }
  }
}

public final class HidDevice: Sendable {
  private final class Handler: @unchecked Sendable {
    private let handler: OpaquePointer
    init(_ handler: consuming OpaquePointer) {
      self.handler = handler
    }

    func callAsFunction() -> OpaquePointer {
      handler
    }
  }
  private let handler: Handler
  private let log: OSLog

  init(
    handler: consuming OpaquePointer
  ) {
    self.handler = .init(handler)
    self.log = OSLog(subsystem: "com.bialiauski.HidApi", category: "Device")
  }

  deinit {
    os_log(.debug, log: log, "Closing device")
    Task.detached { [handler, log] in
      try await hidApiExecutor.execute { [handler, log] in
        hid_close(handler())
        os_log(.info, log: log, "Closed device")
      }
    }
  }

  public func write(_ data: Data) async throws {
    os_log(.debug, log: log, "Writing to device: data=\(data.toHexString())")
    try await hidApiExecutor.execute { [handler, log] in
      try data.withUnsafeBytes { (rawBuffer: UnsafeRawBufferPointer) in
        try rawBuffer.withMemoryRebound(to: UInt8.self) { buffer in
          let result = hid_write(handler(), buffer.baseAddress, rawBuffer.count)
          if result == -1 {
            os_log(.error, log: log, "Failed to write to device: report: \(data.toHexString()), error=\(String.hidApiErrorMessage)")
            throw HidApiError.writeToDeviceFailed(message: .hidApiErrorMessage)
          } else {
            os_log(.info, log: log, "Wrote to device report=\(data.toHexString())")
          }
        }
      }
    }
  }

  public func read(timeout: TimeInterval) async throws -> Data {
    os_log(.debug, log: log, "Reading from device")
    let readData: UnfairLocked<Data?> = .init(nil, lock: .init())
    try await hidApiExecutor.execute { [handler, log] in
      var dataBuffer = Array<UInt8>(repeating: 0, count: 32)
      let bytesread = dataBuffer.withUnsafeMutableBufferPointer { buf in
        let hidTimeout = Int32(timeout * 1000)
        return Int(hid_read_timeout(handler(), buf.baseAddress!, 32, hidTimeout))
      }
      if bytesread == -1 {
        let error = String.hidApiErrorMessage
        os_log(.error, log: log, "Failed to read from device: error=\(error)")
        throw HidApiError.readTimeout(message: error)
      }
      else if bytesread == 0 {
        os_log(.error, log: log, "Failed to read from device due to timeout")
        throw HidApiError.readTimeout(message: "No report received from device")
      }
      else {
        let data = Data(dataBuffer[0..<bytesread])
        os_log(.info, log: log, "Read from device: data=\(data.toHexString())")
        readData.mutate { $0 = data }
      }
    }

    guard let data = readData.mutate({ $0 }) else {
      preconditionFailure("Unreachable")
    }

    return data
  }
}

extension String {
  static var hidApiErrorMessage: String {
    if let cMessage = hid_error(nil) {
      .init(cMessage)
    } else {
      .unknownErrorMessage
    }
  }
}
