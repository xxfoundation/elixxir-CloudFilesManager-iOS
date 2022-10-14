import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class DropboxIsLinkedTests: XCTestCase {
  func testIsLinked() throws {
    var didRequestIsLinked: Bool?
    var client: Dropbox = .unimplemented
    client._isLinked = {
      didRequestIsLinked = true
      return true
    }
    let isLinked: IsLinked = .dropbox(client: client)
    XCTAssertEqual(isLinked(), didRequestIsLinked)
    XCTAssertNotNil(didRequestIsLinked)
  }
}
