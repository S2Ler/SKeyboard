public import Foundation

public protocol FileDataType: Codable {

}

public protocol Coder<DataType>: Sendable {
  associatedtype DataType: Codable

  func encode(_ value: DataType) throws -> Data
  func decode(from data: Data) throws -> DataType
}

public struct SecurityScopedResourceAccess: ~Copyable {
  private var accessGranted: Bool = false
  public let url: URL

  public init(url: URL) {
    self.url = url
    accessGranted = url.startAccessingSecurityScopedResource()
  }

  deinit {
    guard accessGranted else { return }
    url.stopAccessingSecurityScopedResource()
  }
}

public final class FileStorage<
  DataType: FileDataType,
  CoderType: Coder<DataType>
> {
  public struct Configuration: Sendable {
    public let fileUrl: URL
    public let coder: CoderType
    public let writingOptions: Data.WritingOptions

    public init(
      fileUrl: URL,
      coder: CoderType,
      writingOptions: Data.WritingOptions
    ) {
      self.fileUrl = fileUrl
      self.coder = coder
      self.writingOptions = writingOptions
    }
  }

  private let configuration: Configuration

  public init(configuration: Configuration) {
    self.configuration = configuration
  }

  public func save(_ data: DataType) async throws {
    let data = try configuration.coder.encode(data)
    let coordinator = NSFileCoordinator()
    var error: NSError?
    var writingError: Error?

    coordinator.coordinate(
      writingItemAt: configuration.fileUrl,
      options: .forReplacing,
      error: &error
    ) { [writingOptions = configuration.writingOptions] url in
        do {
          try data.write(to: url, options: writingOptions)
        } catch {
          writingError = error
        }
      }

    if let error {
      throw error
    }
    if let writingError {
      throw writingError
    }
  }

  public func load() async throws -> DataType? {
    let coordinator = NSFileCoordinator()
    var error: NSError?
    var readingError: Error?
    let url = configuration.fileUrl

    let scopedUrl = SecurityScopedResourceAccess(url: url)

    var value: DataType?

    coordinator.coordinate(
      readingItemAt: url,
      error: &error
    ) { url in
        do {
          let data = try Data(contentsOf: url, options: .uncached)
          value = try configuration.coder.decode(from: data)
        } catch {
          readingError = error
        }
      }

    _ = consume scopedUrl

    if let error {
      throw error
    }
    if let readingError {
      throw readingError
    }

    return value
  }
}
