import Shout
import Foundation
import CloudFiles

public struct SFTPClient {
  typealias DownloadCompletion = (Result<Data?, Swift.Error>) -> Void
  typealias FetchCompletion = (Result<Fetch.Metadata?, Swift.Error>) -> Void
  typealias UploadCompletion = (Result<Upload.Metadata, Swift.Error>) -> Void

  public enum SFTPError: Swift.Error {
    case unknown
    case fetch(Error)
    case upload(Error)
    case download(Error)
  }

  var _link: () -> Void
  var _unlink: () -> Void
  var _isLinked: () -> Bool
  var _fetch: (String, @escaping FetchCompletion) -> Void
  var _download: (String, @escaping DownloadCompletion) -> Void
  var _upload: (String, Data, @escaping UploadCompletion) -> Void

  func link() {
    _link()
  }

  func unlink() {
    _unlink()
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

extension SFTPClient {
  public static let live = SFTPClient(
    _link: {
      // TODO
    },
    _unlink: {
      // TODO
    },
    _isLinked: {
      // TODO
      false
    },
    _fetch: { fileName, completion in
      // TODO
    },
    _download: { path, completion in
      // TODO
    },
    _upload: { filePath, data, completion in
      // TODO
    }
  )
}

extension CloudFilesManager {
  public static func sftp(
    fileName: String
  ) -> CloudFilesManager {
    CloudFilesManager(
      link: .sftp(),
      fetch: .sftp(fileName: fileName),
      upload: .sftp(fileName: fileName),
      unlink: .sftp(),
      enable: .unimplemented,
      disable: .unimplemented,
      download: .sftp(fileName: fileName),
      isLinked: .sftp(),
      isEnabled: .unimplemented
    )
  }
}
