import UIKit
import CloudFiles

extension Link {
  public static func drive(
    client: DriveClient = .live,
    apiKey: String,
    clientId: String,
    controller: UIViewController
  ) -> Link {
    Link { completion in
      client.signIn(
        apiKey: apiKey,
        clientId: clientId,
        controller: controller,
        completion: { signInResult in
          switch signInResult {
          case .success(let userAndService):
            client.authorize(
              user: userAndService.0,
              service: userAndService.1,
              controller: controller) { authorizeResult in
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
