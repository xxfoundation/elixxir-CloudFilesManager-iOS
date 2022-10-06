import CloudFiles

extension Download {
  public static func dropbox(client: DropboxClient = .live) -> Download {
    Download { completion in
      client.download(path: "/backup/backup.xxm") { result in
        switch result {
        case .success(let data):
          completion(.success(data))
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
}
