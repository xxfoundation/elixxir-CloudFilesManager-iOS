import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class DropboxUnlinkTests: XCTestCase {
  func testUnlink() throws {
    var didUnlink: Int = 0
    var client: Dropbox = .unimplemented
    client._unlink = { didUnlink += 1 }
    let unlink: Unlink = .dropbox(client: client)
    try unlink()
    XCTAssertEqual(didUnlink, 1)
  }
}
