import CloudFiles

extension Fetch {
  public static func dropbox(client: DropboxClient = .live) -> Fetch {
    Fetch { completion in
      client.fetch(path: "/backup/backup.xxm") { fetchResult in
        switch fetchResult {
        case .success(let metadata):
          completion(.success(.init(
            size: Float(metadata.size),
            lastModified: metadata.serverModified
          )))
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
}
