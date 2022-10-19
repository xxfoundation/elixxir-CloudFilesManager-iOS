import UIKit
import CloudFiles
import GoogleSignIn
import GoogleAPIClientForREST_Drive

public struct Drive {
  typealias SignInCompletion = (Result<Void, Swift.Error>) -> Void
  typealias RestoreCompletion = (Result<Void, Swift.Error>) -> Void
  typealias DownloadCompletion = (Result<Data?, Swift.Error>) -> Void
  typealias AuthorizeCompletion = (Result<Void, Swift.Error>) -> Void
  typealias FetchCompletion = (Result<Fetch.Metadata?, Swift.Error>) -> Void
  typealias UploadCompletion = (Result<Upload.Metadata, Swift.Error>) -> Void

  public enum DriveError: Swift.Error {
    case unknown
    case unauthorized
    case missingScopes
    case fetch(Error)
    case signIn(Error)
    case upload(Error)
    case restore(Error)
    case download(Error)
    case authorize(Error)
  }

  static var service = GTLRDriveService()

  var _unlink: () -> Void
  var _isLinked: () -> Bool
  var _restore: (@escaping RestoreCompletion) -> Void
  var _fetch: (String, @escaping FetchCompletion) -> Void
  var _download: (String, @escaping DownloadCompletion) -> Void
  var _upload: (String?, String, Data, @escaping UploadCompletion) -> Void
  var _authorize: (UIViewController, @escaping AuthorizeCompletion) -> Void
  var _signIn: (String, String, UIViewController, @escaping SignInCompletion) -> Void

  func unlink() {
    _unlink()
  }

  func isLinked() -> Bool {
    _isLinked()
  }

  func restore(
    completion: @escaping RestoreCompletion
  ) {
    _restore(completion)
  }

  func download(
    fileId: String,
    completion: @escaping DownloadCompletion
  ) {
    _download(fileId, completion)
  }

  func upload(
    fileId: String?,
    fileName: String,
    input: Data,
    completion: @escaping UploadCompletion
  ) {
    _upload(fileId, fileName, input, completion)
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

extension Drive {
  public static let unimplemented: Drive = .init(
    _unlink: { fatalError() },
    _isLinked: { fatalError() },
    _restore: { _ in fatalError() },
    _fetch: { _,_ in fatalError() },
    _download: { _,_ in fatalError() },
    _upload: { _,_,_,_ in fatalError() },
    _authorize: { _,_ in fatalError() },
    _signIn: { _,_,_,_ in fatalError() }
  )

  public static let live = Drive(
    _unlink: {
      GIDSignIn.sharedInstance.signOut()
    },
    _isLinked: {
      guard GIDSignIn.sharedInstance.hasPreviousSignIn(),
            let currentUser = GIDSignIn.sharedInstance.currentUser,
            let scopes = currentUser.grantedScopes,
            scopes.contains(kGTLRAuthScopeDriveFile),
            scopes.contains(kGTLRAuthScopeDriveAppdata) else {
        return false
      }
      return true
    },
    _restore: { completion in
      guard GIDSignIn.sharedInstance.hasPreviousSignIn() else {
        completion(.failure(DriveError.unauthorized))
        return
      }
      GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
        if let error {
          completion(.failure(DriveError.restore(error)))
          return
        }
        guard let user,
              let scopes = user.grantedScopes,
              scopes.contains(kGTLRAuthScopeDriveFile),
              scopes.contains(kGTLRAuthScopeDriveAppdata) else {
          completion(.failure(DriveError.unauthorized))
          return
        }
        service.authorizer = user.authentication.fetcherAuthorizer()
        completion(.success(()))
      }
    },
    _fetch: { fileName, completion in
      let query = GTLRDriveQuery_FilesList.query()
      query.q = "name = '\(fileName)'"
      query.spaces = "appDataFolder"
      query.fields = "files(id, size, modifiedTime)"
      service.executeQuery(query) { _, result, error in
        if let error {
          if (error as NSError).domain == kGTLRErrorObjectDomain, (error as NSError).code == 404 {
            completion(.success(nil))
            return
          }
          completion(.failure(DriveError.fetch(error)))
          return
        }
        guard let listMetadata = (result as? GTLRDrive_FileList)?.files else {
          completion(.failure(DriveError.unknown))
          return
        }
        guard let metadata = listMetadata.first,
              let date = metadata.modifiedTime?.date,
              let size = metadata.size?.floatValue,
              let id = metadata.identifier else {
          completion(.success(nil))
          return
        }
        completion(.success(.init(
          id: id,
          size: size,
          lastModified: date
        )))
      }
    },
    _download: { fileId, completion in
      let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileId)
      service.executeQuery(query) { _, result, error in
        if let error {
          completion(.failure(DriveError.download(error)))
          return
        }
        guard let file = (result as? GTLRDataObject)?.data else {
          completion(.failure(DriveError.unknown))
          return
        }
        completion(.success(file))
      }
    },
    _upload: { fileId, fileName, data, completion in
      let query: GTLRDriveQuery
      let params = GTLRUploadParameters(
        data: data,
        mimeType: "application/octet-stream"
      )
      if let fileId {
        query = GTLRDriveQuery_FilesUpdate.query(
          withObject: GTLRDrive_File(),
          fileId: fileId,
          uploadParameters: params
        )
      } else {
        query = GTLRDriveQuery_FilesCreate.query(
          withObject: GTLRDrive_File(json: [
            "name":"\(fileName)",
            "parents": ["appDataFolder"],
            "mimeType": "application/octet-stream"
          ]), uploadParameters: params)
      }
      query.fields = "size, modifiedTime"
      service.executeQuery(query) { _, result, error in
        if let error {
          completion(.failure(DriveError.upload(error)))
          return
        }
        guard let file = result as? GTLRDrive_File,
              let size = file.size?.floatValue,
              let date = file.modifiedTime?.date else {
          completion(.failure(DriveError.unknown))
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
        completion(.failure(DriveError.missingScopes))
        return
      }
      service.authorizer = user.authentication.fetcherAuthorizer()
      if !scopes.contains(kGTLRAuthScopeDriveFile) ||
          !scopes.contains(kGTLRAuthScopeDriveAppdata) {
        GIDSignIn.sharedInstance.addScopes([
          kGTLRAuthScopeDriveAppdata,
          kGTLRAuthScopeDriveFile,
        ], presenting: controller) { user, error in
          if let error {
            completion(.failure(DriveError.authorize(error)))
            return
          }
          completion(.success(()))
        }
      } else {
        completion(.success(()))
      }
    },
    _signIn: { apiKey, clientId, controller, completion in
      service.apiKey = apiKey
      GIDSignIn.sharedInstance.signIn(
        with: .init(clientID: clientId),
        presenting: controller) { user, error in
          if let error {
            completion(.failure(DriveError.signIn(error)))
            return
          }
          guard user != nil else {
            completion(.failure(DriveError.unknown))
            return
          }
          completion(.success(()))
        }
    }
  )
}

extension CloudFilesManager {
  public static func drive(
    apiKey: String,
    clientId: String,
    fileName: String
  ) -> CloudFilesManager {
    CloudFilesManager(
      link: .drive(
        apiKey: apiKey,
        clientId: clientId
      ),
      fetch: .drive(fileName: fileName),
      upload: .drive(fileName: fileName),
      unlink: .drive(),
      download: .drive(fileName: fileName),
      isLinked: .drive()
    )
  }
}
