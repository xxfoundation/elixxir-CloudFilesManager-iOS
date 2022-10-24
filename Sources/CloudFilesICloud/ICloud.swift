import UIKit
import CloudFiles

public struct ICloud {
  typealias DownloadCompletion = (Result<Data?, Swift.Error>) -> Void
  typealias FetchCompletion = (Result<Fetch.Metadata?, Swift.Error>) -> Void
  typealias UploadCompletion = (Result<Upload.Metadata, Swift.Error>) -> Void

  public enum ICloudError: Swift.Error {
    case unknown
    case unauthorized
    case fetch(Error)
  }

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
        let manager = FileManager.default
        guard let url = manager.url(forUbiquityContainerIdentifier: nil) else {
          completion(.failure(ICloudError.unauthorized))
          return
        }
        let fileURL: URL = url.appendingPathComponent(fileName)
        if manager.contents(atPath: fileURL.path) == nil {
          do {
            let status = try fileURL.resourceValues(forKeys: [
              .isUbiquitousItemKey,
              .ubiquitousItemIsDownloadingKey,
              .ubiquitousItemDownloadingStatusKey
            ])

            func observeDownload(status: URLResourceValues) throws {
              if status.isUbiquitousItem ?? false {
                if status.ubiquitousItemDownloadingStatus == .current {
                  print("iCloud file is downloaded...")
                } else if status.ubiquitousItemIsDownloading ?? false {
                  try observeDownload(status: status)
                } else {
                  try manager.startDownloadingUbiquitousItem(at: fileURL)
                  try observeDownload(status: status)
                }
              } else {
                throw ICloudError.unknown
              }
            }

            try observeDownload(status: status)
          } catch {
            completion(.failure(ICloudError.fetch(error)))
            return
          }
        }
        guard let file = manager.contents(atPath: fileURL.path),
              let createdAt = try? fileURL.resourceValues(forKeys: [.creationDateKey]).creationDate else {
          completion(.success(nil))
          return
        }
        let modifiedDate = try? fileURL
          .resourceValues(forKeys: [.contentModificationDateKey])
          .contentModificationDate
        completion(.success(.init(
          size: Float(file.count),
          lastModified: modifiedDate ?? createdAt
        )))
      },
      _download: { fileName, completion in
        let manager = FileManager.default
        guard let url = manager.url(forUbiquityContainerIdentifier: nil) else {
          completion(.failure(ICloudError.unauthorized))
          return
        }
        guard let data = manager.contents(atPath: url.appendingPathComponent(fileName).path) else {
          completion(.failure(ICloudError.unknown))
          return
        }
        completion(.success(data))
      },
      _upload: { fileName, data, completion in
        let manager = FileManager.default
        guard let url = manager.url(forUbiquityContainerIdentifier: nil) else {
          completion(.failure(ICloudError.unauthorized))
          return
        }
        let _ = manager.createFile(
          atPath: url.appendingPathComponent(fileName).path,
          contents: data
        )
        completion(.success(.init(
          size: Float(data.count),
          lastModified: Date()
        )))
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
