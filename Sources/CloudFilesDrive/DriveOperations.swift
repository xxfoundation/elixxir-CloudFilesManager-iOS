import UIKit
import CloudFiles
import GoogleSignIn

extension Unlink {
  public static func drive(
    client: Drive = .live
  ) -> Unlink {
    Unlink {
      client.unlink()
    }
  }
}

extension Download {
  public static func drive(
    fileName: String,
    client: Drive = .live
  ) -> Download {
    Download { completion in
      client.fetch(
        fileName: fileName,
        completion: { fetchResult in
          switch fetchResult {
          case .success(let metadata):
            if let metadata, let id = metadata.id {
              client.download(
                fileId: id,
                completion: completion
              )
            }
          case .failure(let error):
            completion(.failure(error))
          }
        }
      )
    }
  }
}

extension Upload {
  public static func drive(
    fileName: String,
    client: Drive = .live
  ) -> Upload {
    Upload { data, completion in
      client.restore { restoreResult in
        switch restoreResult {
        case .success:
          client.fetch(fileName: fileName) { fetchResult in
            var fileId: String?
            switch fetchResult {
            case .success(let metadata):
              fileId = metadata?.id
            case .failure:
              break
            }
            client.upload(
              fileId: fileId,
              fileName: fileName,
              input: data,
              completion: completion
            )
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
}

extension Fetch {
  public static func drive(
    client: Drive = .live,
    fileName: String
  ) -> Fetch {
    Fetch { completion in
      client.restore {
        switch $0 {
        case .success:
          client.fetch(
            fileName: fileName,
            completion: completion
          )
        case .failure(let error):
          completion(.failure(error))
        }
      }
    }
  }
}

extension IsLinked {
  public static func drive(
    client: Drive = .live
  ) -> IsLinked {
    IsLinked {
      client.isLinked()
    }
  }
}

extension Link {
  public static func drive(
    client: Drive = .live,
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
