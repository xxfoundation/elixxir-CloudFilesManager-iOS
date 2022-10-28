import UIKit

public struct CloudFilesManager {
  public var link: Link
  public var fetch: Fetch
  public var upload: Upload
  public var unlink: Unlink
  public var download: Download
  public var isLinked: IsLinked

  public init(
    link: Link,
    fetch: Fetch,
    upload: Upload,
    unlink: Unlink,
    download: Download,
    isLinked: IsLinked
  ) {
    self.link = link
    self.fetch = fetch
    self.upload = upload
    self.unlink = unlink
    self.download = download
    self.isLinked = isLinked
  }
}

public extension CloudFilesManager {
  static var all: [CloudService: CloudFilesManager] = [:]

  static subscript(service: CloudService) -> CloudFilesManager {
    get { all[service] ?? .unimplemented }
    set { all[service] = newValue }
  }

  static let unimplemented: CloudFilesManager = .init(
    link: .unimplemented,
    fetch: .unimplemented,
    upload: .unimplemented,
    unlink: .unimplemented,
    download: .unimplemented,
    isLinked: .unimplemented
  )
}

public extension [CloudService: CloudFilesManager] {
  func linkedServices() -> Set<CloudService> {
    Set(self.filter { $0.value.isLinked() }.map(\.key))
  }

  func lastBackups(
    completion: @escaping ([CloudService: Fetch.Metadata]) -> Void
  ) {
    let group = DispatchGroup()
    var backups: [CloudService: Fetch.Metadata] = [:]
    self.filter { $0.value.isLinked() }.forEach { service, manager in
      group.enter()
      do {
        try manager.fetch {
          if let metadata = try? $0.get() {
            backups[service] = metadata
          }
          group.leave()
        }
      } catch {
        group.leave()
      }
    }
    group.notify(queue: DispatchQueue.main) {
      completion(backups)
    }
  }
}
