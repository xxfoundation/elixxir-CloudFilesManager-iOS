import UIKit
import CloudFiles

extension Unlink {
  public static func drive(
    client: DriveClient = .live()
  ) -> Unlink {
    Unlink { client.unlink() }
  }
}

extension Fetch {
  public static func drive(
    client: DriveClient = .live()
  ) -> Fetch {
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

extension IsLinked {
  public static func drive(client: DriveClient = .live()) -> IsLinked {
    IsLinked { client.isLinked() }
  }
}

extension Link {
  public static func drive(
    client: DriveClient = .live(),
    apiKey: String,
    clientId: String
  ) -> Link {
    Link { controller, completion in
      client.signIn(
        apiKey: apiKey,
        clientId: clientId,
        controller: controller,
        completion: { signInResult in
          switch signInResult {
          case .success:
            client.authorize(
              controller: controller,
              completion: completion
            )
          case .failure(let error):
            completion(.failure(error))
          }
        }
      )
    }
  }
}
