public import HidApi

public struct KeyboardInfo: CustomStringConvertible, Sendable {
  public let vendorId: HidDevice.VendorId
  public let productId: HidDevice.ProductId
  public let usagePage: HidDevice.UsagePage
  public let usage: HidDevice.Usage

  public init(
    vendorId: HidDevice.VendorId,
    productId: HidDevice.ProductId,
    usagePage: HidDevice.UsagePage,
    usage: HidDevice.Usage
  ) {
    self.vendorId = vendorId
    self.productId = productId
    self.usagePage = usagePage
    self.usage = usage
  }

  public var description: String {
    "KeyboardInfo(vendorId: \(vendorId), productId: \(productId), usagePage: \(usagePage), usage: \(usage))"
  }
}
