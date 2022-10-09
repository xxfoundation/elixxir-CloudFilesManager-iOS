import Foundation

public struct Fetch {
  public struct Metadata: Equatable {
    public var id: String?
    public var size: Float
    public var lastModified: Date

    public init(
      id: String? = nil,
      size: Float,
      lastModified: Date
    ) {
      self.id = id
      self.size = size
      self.lastModified = lastModified
    }
  }

  public typealias Completion = (Result<Metadata?, Error>) -> Void

  public var run: (@escaping Completion) throws -> Void

  public func callAsFunction(_ closure: @escaping Completion) throws {
    try run(closure)
  }

  public init(run: @escaping (@escaping Completion) throws -> Void) {
    self.run = run
  }
}

extension Fetch {
  public static let unimplemented = Fetch { _ in
    fatalError()
  }
}
