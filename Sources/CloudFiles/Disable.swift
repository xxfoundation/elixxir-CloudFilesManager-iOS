public struct Disable {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }

  public init(run: @escaping () throws -> Void) {
    self.run = run
  }
}

extension Disable {
  public static let unimplemented = Disable {
    fatalError()
  }
}
