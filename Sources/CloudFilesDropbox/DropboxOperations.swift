import UIKit
import CloudFiles

extension Link {
  public static func dropbox(
    client: DropboxClient = .live,
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
  public static func dropbox(client: DropboxClient = .live) -> IsLinked {
    IsLinked {
      client.isLinked()
    }
  }
}

extension Unlink {
  public static func dropbox(client: DropboxClient = .live) -> Unlink {
    Unlink { client.unlink() }
  }
}

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

extension Download {
  public static func dropbox(
    path: String,
    client: DropboxClient = .live
  ) -> Download {
    Download { client.download(path: path, completion: $0) }
  }
}
