import UIKit
import CloudFiles
import GoogleSignIn
import GoogleAPIClientForREST_Drive

public struct DriveClient {
  typealias SignInCompletion = (Result<Void, Swift.Error>) -> Void
  typealias AuthorizeCompletion = (Result<Void, Swift.Error>) -> Void
  typealias FetchCompletion = (Result<Fetch.Metadata?, Swift.Error>) -> Void
  typealias UploadCompletion = (Result<Upload.Metadata, Swift.Error>) -> Void

  public enum DriveClientError: Swift.Error {
    case unknown
    case missingScopes
    case fetch(Error)
    case signIn(Error)
    case upload(Error)
    case authorize(Error)
  }

  static var service = GTLRDriveService()

  var _unlink: () -> Void
  var _isLinked: () -> Bool
  var _fetch: (String, @escaping FetchCompletion) -> Void
  var _upload: (String, Data, @escaping UploadCompletion) -> Void
  var _authorize: (UIViewController, @escaping AuthorizeCompletion) -> Void
  var _signIn: (String, String, UIViewController, @escaping SignInCompletion) -> Void

  func unlink() {
    _unlink()
  }

  func isLinked() -> Bool {
    _isLinked()
  }

  func upload(
    path: String,
    input: Data,
    completion: @escaping UploadCompletion
  ) {
    _upload(path, input, completion)
  }

  func fetch(
    fileName: String,
    completion: @escaping FetchCompletion
  ) {
    _fetch(fileName, completion)
  }

  func authorize(
    controller: UIViewController,
    completion: @escaping AuthorizeCompletion
  ) {
    _authorize(controller, completion)
  }

  func signIn(
    apiKey: String,
    clientId: String,
    controller: UIViewController,
    completion: @escaping SignInCompletion
  ) {
    _signIn(apiKey, clientId, controller, completion)
  }
}

extension DriveClient {
  public static let live = DriveClient(
    _unlink: {
      GIDSignIn.sharedInstance.signOut()
    },
    _isLinked: {
      guard let currentUser = GIDSignIn.sharedInstance.currentUser,
            let grantedScopes = currentUser.grantedScopes,
            grantedScopes.contains(kGTLRAuthScopeDriveFile),
            grantedScopes.contains(kGTLRAuthScopeDriveAppdata) else { return false }
      return true
    },
    _fetch: { fileName, completion in
      let query = GTLRDriveQuery_FilesList.query()
      query.q = "name = '\(fileName)'"
      query.spaces = "appDataFolder"
      query.fields = "files(size, modifiedTime)"
      service.executeQuery(query) { _, result, error in
        if let error {
          if (error as NSError).domain == kGTLRErrorObjectDomain, (error as NSError).code == 404 {
            completion(.success(nil))
            return
          }
          completion(.failure(DriveClientError.fetch(error)))
          return
        }
        guard let metadata = (result as? GTLRDrive_FileList)?.files?.first,
              let size = metadata.size?.floatValue else {
          completion(.failure(DriveClientError.unknown))
          return
        }
        completion(.success(.init(
          size: size,
          lastModified: metadata.modifiedTime?.date
        )))
      }
    },
    _upload: { path, data, completion in
      let file = GTLRDrive_File(json: [
        "name":"backup.xxm",
        "parents": ["appDataFolder"],
        "mimeType": "application/octet-stream"
      ])
      let params = GTLRUploadParameters(data: data, mimeType: "application/octet-stream")
      let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: params)
      query.fields = "size, modifiedTime"
      service.executeQuery(query) { _, result, error in
        if let error {
          completion(.failure(DriveClientError.upload(error)))
          return
        }
        guard let file = result as? GTLRDrive_File,
              let size = file.size?.floatValue,
              let date = file.modifiedTime?.date else {
          completion(.failure(DriveClientError.unknown))
          return
        }
        completion(.success(.init(
          size: size,
          lastModified: date
        )))
      }
    },
    _authorize: { controller, completion in
      guard let user = GIDSignIn.sharedInstance.currentUser,
            let scopes = user.grantedScopes else {
        completion(.failure(DriveClientError.missingScopes))
        return
      }
      service.authorizer = user.authentication.fetcherAuthorizer()
      if !scopes.contains(kGTLRAuthScopeDriveFile) ||
          !scopes.contains(kGTLRAuthScopeDriveAppdata) {
        GIDSignIn.sharedInstance.addScopes([
          kGTLRAuthScopeDriveAppdata,
          kGTLRAuthScopeDriveFile,
        ], presenting: controller, callback: { user, error in
          if let error {
            completion(.failure(DriveClientError.authorize(error)))
            return
          }
          completion(.success(()))
        })
      } else {
        completion(.success(()))
      }
    },
    _signIn: { apiKey, clientId, controller, completion in
      service.apiKey = apiKey
      GIDSignIn.sharedInstance.signIn(
        with: .init(clientID: clientId),
        presenting: controller,
        callback: { user, error in
          if let error {
            completion(.failure(DriveClientError.signIn(error)))
            return
          }
          guard user != nil else {
            completion(.failure(DriveClientError.unknown))
            return
          }
          completion(.success(()))
        }
      )
    }
  )
}

extension CloudFilesManager {
  public static func drive(
    apiKey: String,
    clientId: String
  ) -> CloudFilesManager {
    CloudFilesManager(
      link: .drive(
        apiKey: apiKey,
        clientId: clientId
      ),
      fetch: .drive(fileName: "backup.xxm"),
      upload: .drive(path: "/backup"),
      unlink: .drive(),
      enable: .unimplemented,
      disable: .unimplemented,
      download: .drive(),
      isLinked: .drive(),
      isEnabled: .unimplemented
    )
  }
}
