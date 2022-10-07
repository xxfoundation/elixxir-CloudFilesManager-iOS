import CloudFiles

extension Fetch {
  public static func drive(client: DriveClient = .live()) -> Fetch {
    Fetch { completion in
      client.listFolder(name: "backup") { getFolderResult in
        switch getFolderResult {
        case .success(let folder):
          client.listFiles(at: folder) { listFilesResult in
            switch listFilesResult {
            case .success:
              client.fetch(fileName: "backup.xxm") { fetchResult in
                switch fetchResult {
                case .success:
                  break
                case .failure(let error):
                  completion(.failure(error))
                }
              }
            case .failure(let error):
              completion(.failure(error))
            }
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
}
