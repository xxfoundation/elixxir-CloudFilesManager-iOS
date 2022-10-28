public struct IsLinked {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }

  public init(run: @escaping () -> Bool) {
    self.run = run
  }
}

extension IsLinked {
  public static let unimplemented = IsLinked {
    fatalError()
  }
}
