import Foundation
import HidApi
import AppKit

public typealias LanguageId = UInt8

public actor Keyboard {
  public enum Error: LocalizedError {
    case deviceNotFound(KeyboardInfo)
    case unmappedInputSourceId(SystemInputSourceId)
    case callingKeyboardApiWithoutDevice(apiName: String)

    public var errorDescription: String? {
      switch self {
      case .deviceNotFound(let keyboardInfo):
        return "Device not found \(keyboardInfo)"
      case .unmappedInputSourceId(let inputSourceId):
        return "Unmapped input source id: \(inputSourceId)"
      case .callingKeyboardApiWithoutDevice(let apiName):
        return "Calling keyboard API without device: \(apiName)"
      }
    }
  }

  public struct Configuration {
    public var layerMappings: [AppBundleId: LayerIndex]
    public var languageMappings: [SystemInputSourceId: LanguageId]
  }

  private let info: KeyboardInfo

  private var configuration: Configuration
  private var device: HidDevice?

  private var languageChangeObserver: Task<Void, Swift.Error>?
  private var appChangeObserver: Task<Void, Swift.Error>?

  public init(info: KeyboardInfo, configuration: Configuration) {
    self.info = info
    self.configuration = configuration
  }

  deinit {
    device = nil
    languageChangeObserver?.cancel()
    appChangeObserver?.cancel()
  }

  public func open() async throws {
    close()

    guard let deviceInfo = try await hidApi.queryDevices(
      vendorId: info.vendorId,
      productId: info.productId,
      usagePage: info.usagePage,
      usage: info.usage
    ).first else {
      throw Error.deviceNotFound(info)
    }

    device = try await hidApi.open(path: deviceInfo.path)

    languageChangeObserver = Task.detached { [weak self] in
      for try await _ in InputSource.onChanged() {
        guard let self else { break }
        await inputSourceChanged()
      }
    }

    appChangeObserver = Task.detached { [weak self] in
      let notifications = NSWorkspace.shared.notificationCenter.notifications(
        named: NSWorkspace.didActivateApplicationNotification
      )
      for try await notification in notifications {
        guard let self,
              let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleId = app.bundleIdentifier.map(AppBundleId.init)
        else { break }

        do {
          try await activeAppChanged(bundleId: bundleId)
        }
        catch {
          print("Error handling active app change error=\(error)")
        }
      }
    }


  }

  public func close() {
    device = nil
    languageChangeObserver?.cancel()
    languageChangeObserver = nil
    appChangeObserver = nil
  }

  public func updateLayerMappings(_ mappings: [LayerMapping]) {
    configuration.layerMappings = mappings.reduce(into: [:], { partialResult, mapping in
      partialResult[mapping.appBundleId] = mapping.layerIdx
    })
  }

  public func updateLanguageMappings(_ mappings: [LanguageMapping]) {
    configuration.languageMappings = mappings.reduce(into: [:], { partialResult, mapping in
      partialResult[mapping.systemId] = mapping.keyboardId
    })
  }

  // MARK: - Keyboard API

  private func setLanguageId(_ languageId: LanguageId) async throws {
    guard let device else {
      throw Error.callingKeyboardApiWithoutDevice(apiName: "set language id")
    }
    try await device.write(Data([2, 1, languageId]))
  }

  private func setLayerId(_ layerId: LayerIndex) async throws {
    guard let device else {
      throw Error.callingKeyboardApiWithoutDevice(apiName: "set layer id")
    }
    try await device.write(Data([2, 2, layerId.rawValue]))
  }


  // MARK: - Notifications
  private func inputSourceChanged() async {
    do {
      let currentSourceId = try InputSource.currentId()
      if let languageId = configuration.languageMappings[currentSourceId] {
        try await setLanguageId(languageId)
      } else {
        throw Error.unmappedInputSourceId(currentSourceId)
      }
    }
    catch {
      print(error.localizedDescription)
    }
  }

  private func activeAppChanged(bundleId: AppBundleId) async throws {
    guard let layerId = configuration.layerMappings[bundleId] else {
      return
    }
    do {
      try await setLayerId(layerId)
    }
    catch {
      print(error.localizedDescription)
    }
  }
}
