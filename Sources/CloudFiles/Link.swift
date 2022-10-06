import UIKit

public struct Link {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }

  public init(run: @escaping () throws -> Void) {
    self.run = run
  }
}

extension Link {
  public static let unimplemented = Link {
    fatalError()
  }
}
