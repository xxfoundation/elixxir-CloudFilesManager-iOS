import CloudFiles

extension Fetch {
  public static func dropbox(
    path: String,
    client: DropboxClient = .live
  ) -> Fetch {
    Fetch { completion in
      client.fetch(path: path) { fetchResult in
        switch fetchResult {
        case .success(let metadata):
          if let metadata {
            completion(.success(.init(
              size: Float(metadata.size),
              lastModified: metadata.serverModified
            )))
          } else {
            completion(.success(nil))
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
}
