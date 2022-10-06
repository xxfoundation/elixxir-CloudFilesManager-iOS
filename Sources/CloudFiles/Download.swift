import Foundation

public typealias DownloadResult = (Result<Data?, Error>) -> Void

public struct Download {
  public var run: (@escaping DownloadResult) throws -> Void

  public func callAsFunction(_ closure: @escaping DownloadResult) throws {
    try run(closure)
  }

  public init(run: @escaping (@escaping DownloadResult) throws -> Void) {
    self.run = run
  }
}

extension Download {
  public static let unimplemented = Download { _ in
    fatalError()
  }
}
