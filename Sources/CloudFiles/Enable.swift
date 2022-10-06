public struct Enable {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }

  public init(run: @escaping () throws -> Void) {
    self.run = run
  }
}

extension Enable {
  public static let unimplemented = Enable {
    fatalError()
  }
}
