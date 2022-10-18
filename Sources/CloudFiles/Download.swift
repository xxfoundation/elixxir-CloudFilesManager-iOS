import Foundation

public struct Download {
  public typealias Completion = (Result<Data?, Error>) -> Void

  public var run: (@escaping Completion) throws -> Void

  public func callAsFunction(_ closure: @escaping Completion) throws {
    try run(closure)
  }

  public init(run: @escaping (@escaping Completion) throws -> Void) {
    self.run = run
  }
}

extension Download {
  public static let unimplemented = Download { _ in
    fatalError()
  }
}
