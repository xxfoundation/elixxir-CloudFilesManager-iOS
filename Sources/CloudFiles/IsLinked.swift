public struct IsLinked {
  public var run: () throws -> Bool

  public func callAsFunction() throws -> Bool {
    try run()
  }

  public init(run: @escaping () throws -> Bool) {
    self.run = run
  }
}

extension IsLinked {
  public static let unimplemented = IsLinked {
    fatalError()
  }
}
