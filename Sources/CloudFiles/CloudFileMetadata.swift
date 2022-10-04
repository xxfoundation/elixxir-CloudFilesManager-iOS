import Foundation

public struct CloudFileMetadata {
  public let date: Date
  public let size: CGFloat
  public let service: CloudFileService

  public init(
    date: Date,
    size: CGFloat,
    service: CloudFileService
  ) {
    self.date = date
    self.size = size
    self.service = service
  }
}
