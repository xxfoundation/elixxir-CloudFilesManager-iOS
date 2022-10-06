import Foundation

public typealias FetchResult = (Result<Data?, Error>) -> Void

public struct Fetch {
  public var run: (@escaping FetchResult) throws -> Void

  public func callAsFunction(_ closure: @escaping FetchResult) throws {
    try run(closure)
  }

  public init(run: @escaping (@escaping FetchResult) throws -> Void) {
    self.run = run
  }
}

extension Fetch {
  public static let unimplemented = Fetch { _ in
    fatalError()
  }
}
