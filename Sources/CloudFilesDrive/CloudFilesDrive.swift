import UIKit
import CloudFiles
import GoogleSignIn
import GoogleAPIClientForREST_Drive

extension LinkService {
  static func live(_ controller: UIViewController) -> LinkService {
    LinkService {
      let service = GTLRDriveService()
      service.apiKey = "[xxxxxxxxx]"
      GIDSignIn.sharedInstance.signIn(
        with: .init(clientID: "[xxxxxxxxx]"),
        presenting: controller,
        callback: { user, error in
          guard let user, let scopes = user.grantedScopes, error == nil else { fatalError() }
          service.authorizer = user.authentication.fetcherAuthorizer()
          if !scopes.contains("https://www.googleapis.com/auth/drive.file") ||
             !scopes.contains("https://www.googleapis.com/auth/drive.appdata") {
            GIDSignIn.sharedInstance.addScopes([
              "https://www.googleapis.com/auth/drive.file",
              "https://www.googleapis.com/auth/drive.appdata"
            ], presenting: controller, callback: { user, error in
              guard user != nil, error == nil else { fatalError() }
            })
          }
        }
      )
    }
  }
}

