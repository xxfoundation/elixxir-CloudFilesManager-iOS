import Foundation

public typealias UploadResult = (Result<Void, Error>) -> Void

public struct Upload {
  public var run: (Data, @escaping UploadResult) throws -> Void

  public func callAsFunction(
    _ data: Data,
    _ result: @escaping UploadResult
  ) throws {
    try run(data, result)
  }

  public init(run: @escaping (Data, @escaping UploadResult) throws -> Void) {
    self.run = run
  }
}

extension Upload {
  public static let unimplemented = Upload { _,_ in
    fatalError()
  }
}
