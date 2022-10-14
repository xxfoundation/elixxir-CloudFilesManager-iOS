import UIKit
import CloudFiles

extension Link {
  public static func dropbox(
    client: CloudFilesDropbox = .live(),
    appKey: String,
    application: UIApplication = .shared
  ) -> Link {
    Link { controller, completion in
      client.link(
        appKey: appKey,
        controller: controller,
        application: application
      )
    }
  }
}

extension IsLinked {
  public static func dropbox(
    client: CloudFilesDropbox = .live()
  ) -> IsLinked {
    IsLinked {
      client.isLinked()
    }
  }
}

extension Unlink {
  public static func dropbox(
    client: CloudFilesDropbox = .live()
  ) -> Unlink {
    Unlink {
      client.unlink()
    }
  }
}

extension Upload {
  public static func dropbox(
    path: String,
    client: CloudFilesDropbox = .live()
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
  public static func dropbox(
    path: String,
    client: CloudFilesDropbox = .live()
  ) -> Fetch {
    Fetch { completion in
      client.fetch(path: path) { fetchResult in
        switch fetchResult {
        case .success(let metadata):
          if let metadata {
            completion(.success(.init(
              size: metadata.size,
              lastModified: metadata.lastModified
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

extension Download {
  public static func dropbox(
    path: String,
    client: CloudFilesDropbox = .live()
  ) -> Download {
    Download {
      client.download(
        path: path,
        completion: $0
      )
    }
  }
}
