import UIKit
import CloudFiles

extension Link {
  public static func drive(
    client: DriveClient = .live(),
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
          case .success(let user):
            client.authorize(
              user: user,
              controller: controller
            ) { authorizeResult in
                switch authorizeResult {
                case .success:
                  completion(.success(()))
                case .failure(let error):
                  completion(.failure(error))
                }
              }
          case .failure(let error):
            completion(.failure(error))
          }
        }
      )
    }
  }
}
