extension HidDevice {
  public enum BusType: UInt32, Sendable {
    /** Unknown bus type */
    case unknown = 0x00
    
    /** USB bus
     Specifications:
     https://usb.org/hid */
    case usb = 0x01
    
    /** Bluetooth or Bluetooth LE bus
     Specifications:
     https://www.bluetooth.com/specifications/specs/human-interface-device-profile-1-1-1/
     https://www.bluetooth.com/specifications/specs/hid-service-1-0/
     https://www.bluetooth.com/specifications/specs/hid-over-gatt-profile-1-0/ */
    case bluetooth = 0x02
    
    /** I2C bus
     Specifications:
     https://docs.microsoft.com/previous-versions/windows/hardware/design/dn642101(v=vs.85) */
    case i2c = 0x03
    
    /** SPI bus
     Specifications:
     https://www.microsoft.com/download/details.aspx?id=103325 */
    case spi = 0x04
  }
}
