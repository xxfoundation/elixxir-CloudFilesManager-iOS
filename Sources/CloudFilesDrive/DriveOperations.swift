import UIKit
import CloudFiles

extension Unlink {
  public static func drive(
    client: DriveClient = .live
  ) -> Unlink {
    Unlink { client.unlink() }
  }
}

extension Download {
  public static func drive(
    client: DriveClient = .live
  ) -> Download {
    Download { _ in
      // TODO
    }
  }
}

extension Upload {
  public static func drive(
    path: String,
    client: DriveClient = .live
  ) -> Upload {
    Upload { data, completion in
      client.upload(
        path: path,
        input: data,
        completion: completion
      )
    }
  }
}

extension Fetch {
  public static func drive(
    client: DriveClient = .live,
    fileName: String
  ) -> Fetch {
    Fetch { completion in
      client.fetch(
        fileName: fileName,
        completion: completion
      )
    }
  }
}

extension IsLinked {
  public static func drive(client: DriveClient = .live) -> IsLinked {
    IsLinked { client.isLinked() }
  }
}

extension Link {
  public static func drive(
    client: DriveClient = .live,
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
