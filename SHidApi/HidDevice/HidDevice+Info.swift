import Foundation

extension HidDevice {
  public struct Info: Hashable, Identifiable, Sendable {
    @inlinable
    public var id: String { path }
    /** Platform-specific device path */
    public let path: String

    /** Device Vendor ID */
    public let vendorId: VendorId

    /** Device Product ID */
    public let productId: ProductId

    /** Serial Number */
    public let serialNumber: String

    /** Device Release Number in binary-coded decimal, also known as Device Version Number */
    public let releaseNumber: UInt16

    /** Manufacturer String */
    public let manufacturerString: String

    /** Product string */
    public let productString: String

    /** Usage Page for this Device/Interface (Windows/Mac/hidraw only) */
    public let usagePage: UsagePage

    /** Usage for this Device/Interface (Windows/Mac/hidraw only) */
    public let usage: Usage

    /** The USB interface which this logical device
     represents. Valid only if the device is a USB HID device.
     Set to -1 in all other cases.
     */
    public let interfaceNumber: Int32

    /** Underlying bus type - assuming this is a custom class/struct
     the definition of `HidBusType` is not provided in given code
     */
    public let busType: BusType
  }
}
