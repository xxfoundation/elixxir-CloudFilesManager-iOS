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
