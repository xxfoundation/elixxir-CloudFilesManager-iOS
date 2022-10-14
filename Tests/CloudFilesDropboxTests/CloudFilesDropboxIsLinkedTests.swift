import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class CloudFilesDropboxIsLinkedTests: XCTestCase {
  private var didRequestIsLinked: Bool?
  private var client: CloudFilesDropbox = .unimplemented
  private var manager: CloudFilesManager = .unimplemented

  override func tearDown() {
    didRequestIsLinked = nil
    client = .unimplemented
    manager = .unimplemented
  }

  func testIsLinked() throws {
    client._isLinked = { [weak self] in
      self?.didRequestIsLinked = true
      return true
    }
    manager.isLinked = .dropbox(client: client)
    let isLinked = try manager.isLinked()
    XCTAssertNotNil(didRequestIsLinked)
    XCTAssertEqual(isLinked, didRequestIsLinked)
  }
}
