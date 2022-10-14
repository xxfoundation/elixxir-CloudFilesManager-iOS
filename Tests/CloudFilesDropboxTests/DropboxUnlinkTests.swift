import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class DropboxUnlinkTests: XCTestCase {
  func testUnlink() throws {
    var didUnlink: Bool?
    var client: Dropbox = .unimplemented
    client._unlink = {
      didUnlink = true
    }
    let unlink: Unlink = .dropbox(client: client)
    try unlink()
    XCTAssertNotNil(didUnlink)
    XCTAssertTrue(didUnlink!)
  }
}

