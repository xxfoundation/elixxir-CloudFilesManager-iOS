import UIKit
import CloudFiles
import GoogleSignIn
import GoogleAPIClientForREST_Drive

public struct DriveClient {
  typealias FetchCompletion = (Result<Fetch.Metadata, Swift.Error>) -> Void
  typealias SignInCompletion = (Result<Void, Swift.Error>) -> Void
  typealias AuthorizeCompletion = (Result<Void, Swift.Error>) -> Void
  typealias ListFilesCompletion = (Result<Void, Swift.Error>) -> Void
  typealias ListFolderCompletion = (Result<String, Swift.Error>) -> Void

  public enum DriveClientError: Swift.Error {
    case unknown
    case missingScopes
    case fetch(Error)
    case signIn(Error)
    case authorize(Error)
    case listFiles(Error)
    case listFolder(Error)
  }

  var _unlink: () -> Void
  var _isLinked: () -> Bool
  var _fetch: (String, @escaping FetchCompletion) -> Void
  var _listFiles: (String, @escaping ListFilesCompletion) -> Void
  var _listFolder: (String, @escaping ListFolderCompletion) -> Void
  var _authorize: (UIViewController, @escaping AuthorizeCompletion) -> Void
  var _signIn: (String, String, UIViewController, @escaping SignInCompletion) -> Void

  func unlink() {
    _unlink()
  }

  func isLinked() -> Bool {
    _isLinked()
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
  public static func live() -> DriveClient {
    let service = GTLRDriveService()
    return DriveClient(
      _unlink: {
        GIDSignIn.sharedInstance.signOut()
      },
      _isLinked: {
        let fileScope = "https://www.googleapis.com/auth/drive.file"
        let appDataScope = "https://www.googleapis.com/auth/drive.appdata"
        guard let currentUser = GIDSignIn.sharedInstance.currentUser,
              let grantedScopes = currentUser.grantedScopes,
              grantedScopes.contains(fileScope),
              grantedScopes.contains(appDataScope) else { return false }
        return true
      },
      _fetch: { fileName, completion in
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
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "'\(folderId)' in parents"
        query.spaces = "appDataFolder"
        query.fields = "nextPageToken, files(id, modifiedTime, size, name)"
        service.executeQuery(query) { _, result, error in
          if let error {
            completion(.failure(DriveClientError.listFiles(error)))
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
      _authorize: { controller, completion in
        guard let user = GIDSignIn.sharedInstance.currentUser,
              let scopes = user.grantedScopes else {
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
}

extension CloudFilesManager {
  public static func drive(
    apikey: String,
    clientId: String
  ) -> CloudFilesManager {
    CloudFilesManager(
      link: .drive(
        apiKey: apikey,
        clientId: clientId
      ),
      fetch: .drive(),
      upload: .unimplemented,
      unlink: .drive(),
      enable: .unimplemented,
      disable: .unimplemented,
      download: .unimplemented,
      isLinked: .drive(),
      isEnabled: .unimplemented
    )
  }
}
