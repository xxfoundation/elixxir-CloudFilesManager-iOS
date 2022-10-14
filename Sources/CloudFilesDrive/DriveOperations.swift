import UIKit
import CloudFiles

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
      client.upload(
        fileName: fileName,
        input: data,
        completion: completion
      )
    }
  }
}

extension Fetch {
  public static func drive(
    client: Drive = .live,
    fileName: String
  ) -> Fetch {
    Fetch {
      client.fetch(
        fileName: fileName,
        completion: $0
      )
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
