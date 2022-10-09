import CloudFiles

extension Upload {
  public static func dropbox(
    path: String,
    client: DropboxClient = .live
  ) -> Upload {
    Upload { data, completion in
      client.upload(path: path, input: data) { uploadResult in
        switch uploadResult {
        case .success(let fileMetadata):
          completion(.success(.init(
            size: Float(fileMetadata.size),
            lastModified: fileMetadata.serverModified
          )))
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
}
