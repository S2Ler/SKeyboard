import Foundation

extension Data {
    public func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined(separator: " ")
    }
}
