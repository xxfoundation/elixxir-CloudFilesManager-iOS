import UIKit
import CloudFiles

extension Link {
  public static func dropbox(
    client: DropboxClient = .live,
    appKey: String,
    controller: UIViewController,
    application: UIApplication = .shared
  ) -> Link {
    Link { completion in
      client.link(
        appKey: appKey,
        controller: controller,
        application: application
      )
      completion(.success(()))
    }
  }
}
