import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class DropboxIsLinkedTests: XCTestCase {
  func testIsLinkedWhenClientIsLinked() throws {
    var client: Dropbox = .unimplemented
    client._isLinked = { true }
    let isLinked: IsLinked = .dropbox(client: client)
    XCTAssertTrue(isLinked())
  }

  func testIsLinkedWhenClientIsNotLinked() throws {
    var client: Dropbox = .unimplemented
    client._isLinked = { false }
    let isLinked: IsLinked = .dropbox(client: client)
    XCTAssertFalse(isLinked())
  }
}
