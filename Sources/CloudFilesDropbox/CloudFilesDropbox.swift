import UIKit
import CloudFiles
import SwiftyDropbox

extension LinkService {
  public static func dropbox(_ controller: UIViewController) -> LinkService {
    LinkService {
      DropboxClientsManager.setupWithAppKey("[xxxxxxxxx]")
      let scopeRequest = ScopeRequest(
        scopeType: .user,
        scopes: [
          "files.content.read",
          "files.content.write",
          "files.metadata.read"
        ],
        includeGrantedScopes: false
      )
      DropboxClientsManager.authorizeFromControllerV2(
        UIApplication.shared,
        controller: controller,
        loadingStatusDelegate: nil,
        openURL: { (url: URL) -> Void in
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        },
        scopeRequest: scopeRequest
      )
    }
  }
}
