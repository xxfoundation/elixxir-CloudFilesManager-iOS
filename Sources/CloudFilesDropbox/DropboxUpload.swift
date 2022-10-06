import CloudFiles

extension Upload {
  public static func dropbox(client: DropboxClient = .live) -> Upload {
    Upload { data, completion in
      client.listFolder(path: "/backup") { listFolderResult in
        switch listFolderResult {
        case .success(let listFolderSuccess):
          if !listFolderSuccess.entries.isEmpty {
            client.upload(path: "/backup/backup.xxm", input: data) { uploadResult in
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
          } else {
            client.createFolder(path: "/backup") { createFolderResult in
              switch createFolderResult {
              case .success:
                client.upload(path: "/backup/backup.xxm", input: data) { uploadResult in
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
              case .failure(let error):
                completion(.failure(error))
              }
            }
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
}
