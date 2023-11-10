import CHidApi
import Dispatch

public let hidApi: HidApi = .init()

/// Serial queue for accesses to HID API
internal let hidApiExecutor: HidApiExecutor = .init()

public actor HidApi {
  public struct DeviceOpenOptions: Sendable, Hashable {
    public enum Mode: Sendable, Hashable {
      case exclusive
      case nonExclusive
    }

    public let mode: Mode

    public init(mode: Mode) {
      self.mode = mode
    }
  }
  
  final class UsageToken: Sendable {
    private let onDeinit: @Sendable () -> Void

    init(onDeinit: @Sendable @escaping () -> Void) {
      self.onDeinit = onDeinit
    }

    deinit {
      onDeinit()
    }
  }

  private var activeClientsCount: Int = 0

  fileprivate init() {}

  internal func initializeIfNeeded() async throws {
    try await hidApiExecutor.execute {
      let initResult = hid_init()
      guard initResult == 0 else {
        throw HidApiError.initializationFailed(message: .hidApiErrorMessage)
      }
    }
  }

  internal func deinitialize() async {
    try? await hidApiExecutor.execute {
      _ = hid_exit()
    }
  }

  private func issueUsageToken() async throws -> UsageToken {
    if activeClientsCount == 0 {
      activeClientsCount += 1
      try await initializeIfNeeded()
    } else {
      activeClientsCount += 1
    }

    return .init {
      Task {
        await self.usageTokenDeinited()
      }
    }
  }

  private func usageTokenDeinited() async {
    activeClientsCount -= 1
    if activeClientsCount == 0 {
      await deinitialize()
    }
  }

  public func queryDevices(
    vendorId: HidDevice.VendorId,
    productId: HidDevice.ProductId
  ) async throws -> [HidDevice.Info] {
    let deviceInfos: UnfairLocked<[HidDevice.Info]> = .init([], lock: .init())

    let usageToken = try await issueUsageToken()

    try await hidApiExecutor.execute {
      // Use hid_enumerate to get all device infos for given vendorId and productId
      guard let hidDeviceInfos = hid_enumerate(vendorId.rawValue, productId.rawValue) else {
        throw HidApiError.enumerationFailed(message: .hidApiErrorMessage)
      }

      deviceInfos.mutate {
        $0.append(.init(hidDeviceInfos.pointee))
      }

      // Iterate over hidDeviceInfos to get all device infos
      var currentHidDeviceInfo = hidDeviceInfos.pointee.next
      while let hidDeviceInfo = currentHidDeviceInfo {
        deviceInfos.mutate {
          $0.append(.init(hidDeviceInfo.pointee))
        }
        currentHidDeviceInfo = hidDeviceInfo.pointee.next
      }

      // Free memory allocated by hid_enumerate
      hid_free_enumeration(hidDeviceInfos)
    }

    return withExtendedLifetime(usageToken) {
      deviceInfos.read(\.self)
    }
  }

  public func open(
    vendorId: HidDevice.VendorId,
    productId: HidDevice.ProductId,
    serialNumber: Optional<String>,
    options: DeviceOpenOptions = .init(mode: .nonExclusive)
  ) async throws -> HidDevice {
    let usageToken = try await issueUsageToken()

    try await hidApiExecutor.execute {
      switch options.mode {
      case .exclusive:
        hid_darwin_set_open_exclusive(1)
      case .nonExclusive:
        hid_darwin_set_open_exclusive(0)
      }
    }

    let hidDevice: UnfairLocked<HidDevice?> = .init(nil, lock: .init())

    try await hidApiExecutor.execute {
      let handler: OpaquePointer? = {
        if let serialNumber {
          serialNumber.withWideChars { wideChars in
            hid_open(vendorId.rawValue, productId.rawValue, wideChars)
          }
        } else {
          hid_open(vendorId.rawValue, productId.rawValue, nil)
        }
      }()

      if let handler {
        hidDevice.mutate {
          $0 = .init(handler: handler)
        }
      } else {
        throw HidApiError.openDeviceFailed(message: .hidApiErrorMessage)
      }
    }

    guard let device = hidDevice.read(\.self) else {
      preconditionFailure()
    }

    return withExtendedLifetime(usageToken) {
      return device
    }
  }

  public func open(path: String) async throws -> HidDevice {
    let device: UnfairLocked<HidDevice?> = .init(nil, lock: .init())

    try await hidApiExecutor.execute {
      let handler = hid_open_path(path.cString(using: .utf8))
      if let handler {
        device.mutate {
          $0 = .init(handler: handler)
        }
      }
    }

    guard let device = device.read(\.self) else {
      preconditionFailure()
    }

    return device
  }
}

extension HidDevice.Info {
  init(_ rawInfo: hid_device_info) {
    self.path = String(cString: rawInfo.path)
    self.vendorId = .init(rawValue: rawInfo.vendor_id)
    self.productId = .init(rawValue: rawInfo.product_id)
    self.serialNumber = String(rawInfo.serial_number)
    self.releaseNumber = rawInfo.release_number
    self.manufacturerString = String(rawInfo.manufacturer_string)
    self.productString = String(rawInfo.product_string)
    self.usagePage = .init(rawValue: rawInfo.usage_page)
    self.usage = .init(rawValue: rawInfo.usage)
    self.interfaceNumber = rawInfo.interface_number
    self.busType = .init(rawValue: rawInfo.bus_type.rawValue)!
  }
}
