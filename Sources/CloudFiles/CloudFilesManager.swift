import Foundation

public struct CloudFilesManager {
  var link: LinkService
}

extension CloudFilesManager {
  static let unimplemented = CloudFilesManager(
    link: .unimplemented
  )
}
