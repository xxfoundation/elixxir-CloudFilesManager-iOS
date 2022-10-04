public struct LinkService {
  var run: () throws -> Void

  func callAsFunction() throws {
    try run()
  }

  public init(run: @escaping () throws -> Void) {
    self.run = run
  }
}

extension LinkService {
  static let unimplemented = LinkService {
    fatalError()
  }
}
