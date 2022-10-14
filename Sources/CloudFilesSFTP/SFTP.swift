import Shout
import Foundation
import CloudFiles
import KeychainAccess

public struct SFTP {
  typealias LinkCompletion = (Result<Void, Swift.Error>) -> Void
  typealias DownloadCompletion = (Result<Data?, Swift.Error>) -> Void
  typealias FetchCompletion = (Result<Fetch.Metadata?, Swift.Error>) -> Void
  typealias UploadCompletion = (Result<Upload.Metadata, Swift.Error>) -> Void

  public enum SFTPError: Swift.Error {
    case unknown
    case unauthorized
    case link(Error)
    case fetch(Error)
    case upload(Error)
    case download(Error)
  }

  var _unlink: () -> Void
  var _isLinked: () -> Bool
  var _fetch: (String, @escaping FetchCompletion) -> Void
  var _download: (String, @escaping DownloadCompletion) -> Void
  var _upload: (String, Data, @escaping UploadCompletion) -> Void
  var _link: (String, String, String, @escaping LinkCompletion) -> Void

  static let keychain = Keychain(service: "SFTP-XXM")

  func link(
    host: String,
    username: String,
    password: String,
    completion: @escaping LinkCompletion
  ) {
    _link(host, username, password, completion)
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

extension SFTP {
  public static let unimplemented: SFTP = .init(
    _unlink: { fatalError() },
    _isLinked: { fatalError() },
    _fetch: { _,_ in fatalError() },
    _download: { _,_ in fatalError() },
    _upload: { _,_,_ in fatalError() },
    _link: { _,_,_,_ in fatalError() }
  )

  public static func live() -> SFTP {
    SFTP(
      _unlink: {
        do {
          try keychain.removeAll()
        } catch {
          fatalError("Couldn't remove SFTP keychain stored values: \(error.localizedDescription)")
        }
      },
      _isLinked: {
        if let _ = try? keychain.get("host"),
           let _ = try? keychain.get("pwd"),
           let _ = try? keychain.get("username") {
          return true
        }
        return false
      },
      _fetch: { fileName, completion in
        guard let host = try? keychain.get("host"),
              let password = try? keychain.get("pwd"),
              let username = try? keychain.get("username") else {
          completion(.failure(SFTPError.unauthorized))
          return
        }
        do {
          let ssh = try SSH(host: host, port: 22)
          try ssh.authenticate(username: username, password: password)
          let sftp = try ssh.openSftp()
          let files = try sftp.listFiles(in: "backup")
          let filesMatching = files.filter { $0.0 == "backup.xxm" }
          guard let backup = filesMatching.first else {
            completion(.success(nil))
            return
          }
          completion(.success(.init(
            size: Float(backup.value.size),
            lastModified: backup.value.lastModified
          )))
        } catch {
          completion(.failure(SFTPError.fetch(error)))
        }
      },
      _download: { path, completion in
        guard let host = try? keychain.get("host"),
              let password = try? keychain.get("pwd"),
              let username = try? keychain.get("username") else {
          completion(.failure(SFTPError.unauthorized))
          return
        }
        do {
          let ssh = try SSH(host: host, port: 22)
          try ssh.authenticate(username: username, password: password)
          let sftp = try ssh.openSftp()
          let localURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.elixxir.messenger")!
            .appendingPathComponent("sftp")
          try sftp.download(remotePath: path, localURL: localURL)
          completion(.success(try Data(contentsOf: localURL)))
        } catch {
          completion(.failure(SFTPError.download(error)))
        }
      },
      _upload: { filePath, data, completion in
        guard let host = try? keychain.get("host"),
              let password = try? keychain.get("pwd"),
              let username = try? keychain.get("username") else {
          completion(.failure(SFTPError.unauthorized))
          return
        }
        do {
          let ssh = try SSH(host: host, port: 22)
          try ssh.authenticate(username: username, password: password)
          let sftp = try ssh.openSftp()
          if (try? sftp.listFiles(in: "backup")) == nil {
            try sftp.createDirectory("backup")
          }
          try sftp.upload(data: data, remotePath: filePath)
          completion(.success(.init(
            size: Float(data.count),
            lastModified: Date()
          )))
        } catch {
          completion(.failure(SFTPError.download(error)))
        }
      },
      _link: { host, username, password, completion in
        do {
          try SSH.connect(
            host: host,
            port: 22,
            username: username,
            authMethod: SSHPassword(password),
            execution: { ssh in
              _ = try ssh.openSftp()
              try keychain.set(host, key: "host")
              try keychain.set(password, key: "pwd")
              try keychain.set(username, key: "username")
              completion(.success(()))
            }
          )
        } catch {
          completion(.failure(SFTPError.link(error)))
        }
      }
    )
  }
}

extension CloudFilesManager {
  public static func sftp(
    host: String,
    username: String,
    password: String,
    fileName: String
  ) -> CloudFilesManager {
    CloudFilesManager(
      link: .sftp(
        host: host,
        username: username,
        password: password
      ),
      fetch: .sftp(fileName: fileName),
      upload: .sftp(fileName: fileName),
      unlink: .sftp(),
      download: .sftp(fileName: fileName),
      isLinked: .sftp()
    )
  }
}
