import UIKit
import CloudFiles
import FilesProvider

public struct ICloud {
  typealias DownloadCompletion = (Result<Data?, Swift.Error>) -> Void
  typealias FetchCompletion = (Result<Fetch.Metadata?, Swift.Error>) -> Void
  typealias UploadCompletion = (Result<Upload.Metadata, Swift.Error>) -> Void

  public enum ICloudError: Swift.Error {
    case unknown
    case unauthorized
    case fetch(Error)
    case upload(Error)
    case download(Error)
  }

  static let documentsProvider = CloudFileProvider(
    containerId: "iCloud.xxm-cloud", scope: .data
  )

  var _link: () -> Void
  var _isLinked: () -> Bool
  var _fetch: (String, @escaping FetchCompletion) -> Void
  var _download: (String, @escaping DownloadCompletion) -> Void
  var _upload: (String, Data, @escaping UploadCompletion) -> Void

  func link() {
    _link()
  }

  func isLinked() -> Bool {
    _isLinked()
  }

  func fetch(
    fileName: String,
    completion: @escaping FetchCompletion
  ) {
    _fetch(fileName, completion)
  }

  func upload(
    input: Data,
    fileName: String,
    completion: @escaping UploadCompletion
  ) {
    _upload(fileName, input, completion)
  }

  func download(
    fileName: String,
    completion: @escaping DownloadCompletion
  ) {
    _download(fileName, completion)
  }
}

extension ICloud {
  public static let unimplemented: ICloud = .init(
    _link: { fatalError() },
    _isLinked: { fatalError() },
    _fetch: { _,_ in fatalError() },
    _download: { _,_ in fatalError() },
    _upload: { _,_,_ in fatalError() }
  )

  public static func live() -> ICloud {
    ICloud(
      _link: {
        if let url = URL(string: "App-Prefs:root=CASTLE"), UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
      },
      _isLinked: {
        FileManager.default.ubiquityIdentityToken != nil
      },
      _fetch: { fileName, completion in
        guard let documentsProvider else {
          completion(.failure(ICloudError.unauthorized))
          return
        }
        documentsProvider.contentsOfDirectory(path: "/") { contents, error in
          if let error {
            completion(.failure(ICloudError.fetch(error)))
            return
          }
          guard let file = contents.first(where: { $0.name == fileName }) else {
            completion(.success(nil))
            return
          }
          completion(.success(.init(
            size: Float(file.size),
            lastModified: file.modifiedDate!
          )))
        }
      },
      _download: { path, completion in
        guard let documentsProvider else {
          completion(.failure(ICloudError.unauthorized))
          return
        }
        documentsProvider.contents(path: path) { contents, error in
          if let error {
            completion(.failure(ICloudError.download(error)))
            return
          }
          guard let contents else {
            completion(.failure(ICloudError.unknown))
            return
          }
          completion(.success(contents))
        }
      },
      _upload: { filePath, data, completion in
        guard let documentsProvider else {
          completion(.failure(ICloudError.unauthorized))
          return
        }
        documentsProvider.writeContents(
          path: filePath,
          contents: data,
          overwrite: true
        ) { error in
          if let error {
            completion(.failure(ICloudError.upload(error)))
            return
          }
          completion(.success(.init(
            size: Float(data.count),
            lastModified: Date()
          )))
        }
      }
    )
  }
}

extension CloudFilesManager {
  public static func iCloud(
    fileName: String
  ) -> CloudFilesManager {
    CloudFilesManager(
      link: .iCloud(),
      fetch: .iCloud(fileName: fileName),
      upload: .iCloud(fileName: fileName),
      unlink: .iCloud(),
      download: .iCloud(fileName: fileName),
      isLinked: .iCloud()
    )
  }
}
