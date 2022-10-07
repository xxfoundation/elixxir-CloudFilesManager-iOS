import UIKit
import SwiftyDropbox

public struct DropboxClient {
  typealias DownloadCompletion = (Result<Data, Swift.Error>) -> Void
  typealias FetchCompletion = (Result<Files.FileMetadata, Swift.Error>) -> Void
  typealias UploadCompletion = (Result<Files.FileMetadata, Swift.Error>) -> Void
  typealias ListFolderCompletion = (Result<Files.ListFolderResult, Swift.Error>) -> Void
  typealias CreateFolderCompletion = (Result<Files.CreateFolderResult, Swift.Error>) -> Void

  public enum Error: Swift.Error {
    case unknown
    case noMetadata
    case unauthorized
    case fetch(CallError<Files.GetMetadataError>)
    case upload(CallError<Files.UploadError>)
    case download(CallError<Files.DownloadError>)
    case listFolder(CallError<Files.ListFolderError>)
    case createFolder(CallError<Files.CreateFolderError>)
  }

  var _unlink: () -> Void
  var _isLinked: () -> Bool
  var _fetch: (String, @escaping FetchCompletion) -> Void
  var _link: (String, UIViewController, UIApplication) -> Void
  var _download: (String, @escaping DownloadCompletion) -> Void
  var _upload: (String, Data, @escaping UploadCompletion) -> Void
  var _listFolder: (String, @escaping ListFolderCompletion) -> Void
  var _createFolder: (String, @escaping CreateFolderCompletion) -> Void

  func unlink() {
    _unlink()
  }

  func isLinked() -> Bool {
    _isLinked()
  }

  func fetch(path: String, completion: @escaping FetchCompletion) {
    _fetch(path, completion)
  }

  func download(path: String, completion: @escaping DownloadCompletion) {
    _download(path, completion)
  }

  func listFolder(path: String, completion: @escaping ListFolderCompletion) {
    _listFolder(path, completion)
  }

  func createFolder(path: String, completion: @escaping CreateFolderCompletion) {
    _createFolder(path, completion)
  }

  func upload(path: String, input: Data, completion: @escaping UploadCompletion) {
    _upload(path, input, completion)
  }

  func link(appKey: String, controller: UIViewController, application: UIApplication) {
    _link(appKey, controller, application)
  }
}

extension DropboxClient {
  public static let live = DropboxClient(
    _unlink: {
      DropboxClientsManager.unlinkClients()
    },
    _isLinked: {
      DropboxClientsManager.authorizedClient != nil
    },
    _fetch: { path, completion in
      guard let client = DropboxClientsManager.authorizedClient else {
        completion(.failure(Error.unauthorized))
        return
      }
      client.files.getMetadata(path: path).response { response, error in
        if let error {
          completion(.failure(Error.fetch(error)))
          return
        }
        if let result = response as? Files.FileMetadata {
          completion(.success(result))
          return
        }
        completion(.failure(Error.noMetadata))
      }
    },
    _link: { appKey, controller, application in
      DropboxClientsManager.setupWithAppKey(appKey)
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
        application,
        controller: controller,
        loadingStatusDelegate: nil,
        openURL: { (url: URL) -> Void in
          application.open(url, options: [:], completionHandler: nil)
        },
        scopeRequest: scopeRequest
      )
    },
    _download: { path, completion in
      guard let client = DropboxClientsManager.authorizedClient else {
        completion(.failure(Error.unauthorized))
        return
      }
      client.files.download(path: path).response { response, error in
        if let error {
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
        completion(.success(response))
      }
    },
    _listFolder: { path, completion in
      guard let client = DropboxClientsManager.authorizedClient else {
        completion(.failure(Error.unauthorized))
        return
      }
      client.files.listFolder(path: path).response { result, error in
        if let error {
          completion(.failure(Error.listFolder(error)))
          return
        }
        guard let result else {
          completion(.failure(Error.unknown))
          return
        }
        completion(.success(result))
      }
    },
    _createFolder: { path, completion in
      guard let client = DropboxClientsManager.authorizedClient else {
        completion(.failure(Error.unauthorized))
        return
      }
      client.files.createFolderV2(path: path).response { result, error in
        if let error {
          completion(.failure(Error.createFolder(error)))
          return
        }
        guard let result else {
          completion(.failure(Error.unknown))
          return
        }
        completion(.success(result))
      }
    }
  )
}
