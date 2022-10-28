import UIKit

public struct Link {
  public typealias Completion = (Result<Void, Error>) -> Void

  public var run: (UIViewController, @escaping Completion) throws -> Void

  public func callAsFunction(
    _ controller: UIViewController,
    _ closure: @escaping Completion
  ) throws {
    try run(controller, closure)
  }

  public init(run: @escaping (UIViewController, @escaping Completion) throws -> Void) {
    self.run = run
  }
}

extension Link {
  public static let unimplemented = Link { _,_ in
    fatalError()
  }
}
