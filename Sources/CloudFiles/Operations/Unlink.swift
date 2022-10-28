public struct Unlink {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }

  public init(run: @escaping () throws -> Void) {
    self.run = run
  }
}

extension Unlink {
  public static let unimplemented = Unlink {
    fatalError()
  }
}
