import UIKit
import CloudFiles
import SwiftyDropbox

var linkCompletion: Link.Completion?

public func handleRedirectURL(_ url: URL) -> Bool {
  DropboxClientsManager.handleRedirectURL(url) {
    if let authResult = $0 {
      switch authResult {
      case .success:
        linkCompletion?(.success(()))
      case .error, .cancel:
        linkCompletion?(.failure(NSError(domain: "", code: 0)))
      }
      linkCompletion = nil
    }
  }
}

extension Link {
  public static func dropbox(
    client: Dropbox = .live(),
    appKey: String,
    application: UIApplication = .shared
  ) -> Link {
    Link { controller, completion in
      linkCompletion = completion
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
    client: Dropbox = .live()
  ) -> IsLinked {
    IsLinked {
      client.isLinked()
    }
  }
}

extension Unlink {
  public static func dropbox(
    client: Dropbox = .live()
  ) -> Unlink {
    Unlink {
      client.unlink()
    }
  }
}

extension Upload {
  public static func dropbox(
    path: String,
    client: Dropbox = .live()
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
    client: Dropbox = .live()
  ) -> Fetch {
    Fetch { completion in
      client.fetch(
        path: path,
        completion: completion
      )
    }
  }
}

extension Download {
  public static func dropbox(
    path: String,
    client: Dropbox = .live()
  ) -> Download {
    Download {
      client.download(
        path: path,
        completion: $0
      )
    }
  }
}
