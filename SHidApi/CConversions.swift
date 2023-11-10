import Foundation

extension String {
  /// Calls the given closure with a pointer to the contents of the string,
  /// represented as a null-terminated wchar_t array.
  func withWideChars<Result>(_ body: (UnsafePointer<wchar_t>) -> Result) -> Result {
    let u32 = self.unicodeScalars.map { wchar_t(bitPattern: $0.value) } + [0]
    return u32.withUnsafeBufferPointer { body($0.baseAddress!) }
  }

  init(_ wideChars: UnsafePointer<wchar_t>) {
    let byteSize = wcslen(wideChars) * MemoryLayout<wchar_t>.stride
    let data = Data(bytes: wideChars, count: byteSize)
    let encoding: String.Encoding = (1.littleEndian == 1) ? .utf32LittleEndian : .utf32BigEndian
    self.init(data: data, encoding: encoding)!
  }

  init(_ wideChars: UnsafeMutablePointer<wchar_t>) {
    let byteSize = wcslen(wideChars) * MemoryLayout<wchar_t>.stride
    let data = Data(bytes: wideChars, count: byteSize)
    let encoding: String.Encoding = (1.littleEndian == 1) ? .utf32LittleEndian : .utf32BigEndian
    self.init(data: data, encoding: encoding)!
  }
}

extension String {
  static let unknownErrorMessage: String = "Unknown error"
}
