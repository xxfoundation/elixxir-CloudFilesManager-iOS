public struct CloudFilesManager {
  public var link: LinkService

  public init(link: LinkService) {
    self.link = link
  }
}

extension CloudFilesManager {
  public static let unimplemented = CloudFilesManager(
    link: .unimplemented
  )
}
