import UIKit
import CloudFiles
import SwiftyDropbox

public struct Dropbox {
  typealias DownloadCompletion = (Result<Data?, Swift.Error>) -> Void
  typealias FetchCompletion = (Result<Fetch.Metadata?, Swift.Error>) -> Void
  typealias UploadCompletion = (Result<Upload.Metadata, Swift.Error>) -> Void

  public enum Error: Swift.Error {
    case unknown
    case abortedLink
    case unauthorized
    case link(OAuth2Error)
    case fetch(CallError<Files.GetMetadataError>)
    case upload(CallError<Files.UploadError>)
    case download(CallError<Files.DownloadError>)
  }

  var _unlink: () -> Void
  var _isLinked: (String) -> Bool
  var _fetch: (String, @escaping FetchCompletion) -> Void
  var _link: (String, UIViewController, UIApplication) -> Void
  var _download: (String, @escaping DownloadCompletion) -> Void
  var _upload: (String, Data, @escaping UploadCompletion) -> Void

  func unlink() {
    _unlink()
  }

  func isLinked(appKey: String) -> Bool {
    _isLinked(appKey)
  }

  func fetch(
    path: String,
    completion: @escaping FetchCompletion
  ) {
    _fetch(path, completion)
  }

  func download(
    path: String,
    completion: @escaping DownloadCompletion
  ) {
    _download(path, completion)
  }

  func upload(
    path: String,
    input: Data,
    completion: @escaping UploadCompletion
  ) {
    _upload(path, input, completion)
  }

  func link(
    appKey: String,
    controller: UIViewController,
    application: UIApplication
  ) {
    _link(appKey, controller, application)
  }
}

extension Dropbox {
  public static let unimplemented: Dropbox = .init(
    _unlink: { fatalError() },
    _isLinked: { _ in fatalError() },
    _fetch: { _,_ in fatalError() },
    _link: { _,_,_ in fatalError() },
    _download: { _,_ in fatalError() },
    _upload: { _,_,_ in fatalError() }
  )

  public static func live() -> Dropbox {
    Dropbox(
      _unlink: {
        DropboxClientsManager.unlinkClients()
      },
      _isLinked: { appKey in
        if DropboxOAuthManager.sharedOAuthManager == nil {
          DropboxClientsManager.setupWithAppKey(appKey)
        }
        return DropboxClientsManager.authorizedClient != nil
      },
      _fetch: { path, completion in
        guard let client = DropboxClientsManager.authorizedClient else {
          completion(.failure(Error.unauthorized))
          return
        }
        client.files.getMetadata(path: path).response { response, error in
          if let error {
            if case .routeError = error {
              completion(.success(nil))
              return
            }
            completion(.failure(Error.fetch(error)))
            return
          }
          if let result = response as? Files.FileMetadata {
            completion(.success(Fetch.Metadata(
              size: Float(result.size),
              lastModified: result.serverModified
            )))
            return
          }
          fatalError("DropboxClient.Fetch brought no results and no errors")
        }
      },
      _link: { appKey, controller, application in
        if DropboxOAuthManager.sharedOAuthManager == nil {
          DropboxClientsManager.setupWithAppKey(appKey)
        }
        DropboxClientsManager.authorizeFromControllerV2(
          application,
          controller: controller,
          loadingStatusDelegate: nil,
          openURL: { (url: URL) -> Void in
            application.open(url, options: [:], completionHandler: nil)
          },
          scopeRequest: ScopeRequest(
            scopeType: .user,
            scopes: [],
            includeGrantedScopes: true
          )
        )
      },
      _download: { path, completion in
        guard let client = DropboxClientsManager.authorizedClient else {
          completion(.failure(Error.unauthorized))
          return
        }
        client.files.download(path: path).response { response, error in
          if let error {
            if case .routeError = error {
              completion(.success(nil))
              return
            }
            completion(.failure(Error.download(error)))
            return
          }
          guard let response else {
            completion(.failure(Error.unknown))
            return
          }
          completion(.success(response.1))
        }
      },
      _upload: { path, input, completion in
        guard let client = DropboxClientsManager.authorizedClient else {
          completion(.failure(Error.unauthorized))
          return
        }
        client.files.upload(path: path, mode: .overwrite, input: input).response { response, error in
          if let error {
            completion(.failure(Error.upload(error)))
            return
          }
          guard let response else {
            completion(.failure(Error.unknown))
            return
          }
          completion(.success(.init(
            size: Float(response.size),
            lastModified: response.serverModified
          )))
        }
      }
    )
  }
}

extension CloudFilesManager {
  public static func dropbox(
    appKey: String,
    path: String
  ) -> CloudFilesManager {
    CloudFilesManager(
      link: .dropbox(appKey: appKey),
      fetch: .dropbox(path: path),
      upload: .dropbox(path: path),
      unlink: .dropbox(),
      download: .dropbox(path: path),
      isLinked: .dropbox(appKey: appKey)
    )
  }
}
