extension HidDevice {
  public struct VendorId: RawRepresentable, Sendable, Codable, CustomStringConvertible, Hashable {
    public var rawValue: UInt16

    public init(rawValue: UInt16) {
      self.rawValue = rawValue
    }

    /// Returns Hexadecimal representation of the usage in format 0xXX
    public var description: String {
      "0x\(String(rawValue, radix: 16, uppercase: true))"
    }
  }
}
