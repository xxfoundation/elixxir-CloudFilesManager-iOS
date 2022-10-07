import UIKit

public struct Link {
  public typealias Completion = (Result<Void, Error>) -> Void

  public var run: (@escaping Completion) throws -> Void

  public func callAsFunction(_ closure: @escaping Completion) throws {
    try run(closure)
  }

  public init(run: @escaping (@escaping Completion) throws -> Void) {
    self.run = run
  }
}

extension Link {
  public static let unimplemented = Link { _ in
    fatalError()
  }
}
