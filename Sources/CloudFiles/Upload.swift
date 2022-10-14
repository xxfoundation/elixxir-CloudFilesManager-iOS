import Foundation

public struct Upload {
  public struct Metadata: Equatable {
    public var size: Float
    public var lastModified: Date

    public init(
      size: Float,
      lastModified: Date
    ) {
      self.size = size
      self.lastModified = lastModified
    }
  }

  public typealias Completion = (Result<Metadata, Error>) -> Void

  public var run: (Data, @escaping Completion) throws -> Void

  public func callAsFunction(_ data: Data, _ result: @escaping Completion) throws {
    try run(data, result)
  }

  public init(run: @escaping (Data, @escaping Completion) throws -> Void) {
    self.run = run
  }
}

extension Upload {
  public static let unimplemented = Upload { _,_ in
    fatalError()
  }
}
