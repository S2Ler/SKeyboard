public struct LanguageMapping {
  public let systemId: SystemInputSourceId
  public let keyboardId: LanguageId

  public init(
    systemId: SystemInputSourceId,
    keyboardId: LanguageId
  ) {
    self.systemId = systemId
    self.keyboardId = keyboardId
  }
}

public struct SystemInputSourceId: Hashable, Sendable {
  internal let rawValue: String

  internal init(rawValue: String) {
    self.rawValue = rawValue
  }
}
