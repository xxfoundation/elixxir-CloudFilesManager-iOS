public struct IsEnabled {
  public var run: () throws -> Bool

  public func callAsFunction() throws -> Bool {
    try run()
  }

  public init(run: @escaping () throws -> Bool) {
    self.run = run
  }
}

extension IsEnabled {
  public static let unimplemented = IsEnabled {
    fatalError()
  }
}
