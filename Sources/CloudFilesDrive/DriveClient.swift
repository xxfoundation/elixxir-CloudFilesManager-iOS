import UIKit
import CloudFiles
import GoogleSignIn
import GoogleAPIClientForREST_Drive

public struct DriveClient {
  typealias FetchCompletion = (Result<Fetch.Metadata, Swift.Error>) -> Void
  typealias AuthorizeCompletion = (Result<Void, Swift.Error>) -> Void
  typealias ListFilesCompletion = (Result<Void, Swift.Error>) -> Void
  typealias ListFolderCompletion = (Result<String, Swift.Error>) -> Void
  typealias SignInCompletion = (Result<(GIDGoogleUser, GTLRDriveService), Swift.Error>) -> Void

  enum DriveClientError: Swift.Error {
    case unknown
    case missingScopes
    case fetch(Error)
    case signIn(Error)
    case authorize(Error)
    case listFiles(Error)
    case listFolder(Error)
  }

  var _signOut: () -> Void
  var _fetch: (String, @escaping FetchCompletion) -> Void
  var _listFiles: (String, @escaping ListFilesCompletion) -> Void
  var _listFolder: (String, @escaping ListFolderCompletion) -> Void
  var _signIn: (String, String, UIViewController, @escaping SignInCompletion) -> Void
  var _authorize: (GIDGoogleUser, GTLRDriveService, UIViewController, @escaping AuthorizeCompletion) -> Void

  func signOut() {
    _signOut()
  }

  func listFolder(
    name: String,
    completion: @escaping ListFolderCompletion
  ) {
    _listFolder(name, completion)
  }

  func listFiles(
    at folder: String,
    completion: @escaping ListFilesCompletion
  ) {
    _listFiles(folder, completion)
  }

  func fetch(
    fileName: String,
    completion: @escaping FetchCompletion
  ) {
    _fetch(fileName, completion)
  }

  func authorize(
    user: GIDGoogleUser,
    service: GTLRDriveService,
    controller: UIViewController,
    completion: @escaping AuthorizeCompletion
  ) {
    _authorize(user, service, controller, completion)
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
    _signOut: {
      GIDSignIn.sharedInstance.signOut()
    },
    _fetch: { fileName, completion in
      let service = GTLRDriveService() // Shouldn't this be stored? <<<
      let query = GTLRDriveQuery_FilesList.query()
      query.q = "'\("folder")' in parents and name = '\(fileName)'"
      query.spaces = "appDataFolder"
      query.fields = "nextPageToken, files(id, size, name, modifiedTime)"
      service.executeQuery(query) { _, result, error in
        if let error {
          completion(.failure(DriveClientError.fetch(error)))
          return
        }
        guard let metadata = (result as? GTLRDrive_FileList)?.files?.first, let size = metadata.size?.floatValue else {
          completion(.failure(DriveClientError.unknown))
          return
        }
        completion(.success(.init(
          size: size,
          lastModified: metadata.modifiedTime?.date
        )))
      }
    },
    _listFiles: { folderId, completion in
      let service = GTLRDriveService() // Shouldn't this be stored? <<<
      let query = GTLRDriveQuery_FilesList.query()
      query.q = "'\(folderId)' in parents"
      query.spaces = "appDataFolder"
      query.fields = "nextPageToken, files(id, modifiedTime, size, name)"
      service.executeQuery(query) { _, result, error in
        if let error {
          completion(.failure(DriveClientError.unknown))
          return
        }
        guard let files = (result as? GTLRDrive_FileList)?.files else {
          completion(.failure(DriveClientError.unknown))
          return
        }
        let metadataList = files.map { _ in }
      }
    },
    _listFolder: { folderName, completion in
      let service = GTLRDriveService() // Shouldn't this be stored? <<<
      let query = GTLRDriveQuery_FilesList.query()
      query.q = "mimeType = 'application/vnd.google-apps.folder' and name = '\(folderName)'"
      query.spaces = "appDataFolder"
      query.fields = "nextPageToken, files(id, name)"
      service.executeQuery(query) { _, result, error in
        if let error {
          completion(.failure(DriveClientError.listFolder(error)))
          return
        }
        guard let folderId = (result as? GTLRDrive_FileList)?.files?.first?.identifier else {
          completion(.failure(DriveClientError.unknown))
          return
        }
        completion(.success(folderId))
      }
    },
    _signIn: { apiKey, clientId, controller, completion in
      let service = GTLRDriveService()
      service.apiKey = apiKey
      GIDSignIn.sharedInstance.signIn(
        with: .init(clientID: clientId),
        presenting: controller,
        callback: { user, error in
          if let error {
            completion(.failure(DriveClientError.signIn(error)))
            return
          }
          guard let user else {
            completion(.failure(DriveClientError.unknown))
            return
          }
          completion(.success((user, service)))
        }
      )
    },
    _authorize: { user, service, controller, completion in
      guard let scopes = user.grantedScopes else {
        completion(.failure(DriveClientError.missingScopes))
        return
      }
      service.authorizer = user.authentication.fetcherAuthorizer()
      let fileScope = "https://www.googleapis.com/auth/drive.file"
      let appDataScope = "https://www.googleapis.com/auth/drive.appdata"
      if !scopes.contains(fileScope) || !scopes.contains(appDataScope) {
        GIDSignIn.sharedInstance.addScopes([
          fileScope, appDataScope
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
    }
  )
}
