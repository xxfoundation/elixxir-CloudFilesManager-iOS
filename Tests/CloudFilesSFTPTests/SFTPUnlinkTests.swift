import XCTest
import CloudFiles
@testable import CloudFilesSFTP

final class SFTPUnlinkTests: XCTestCase {
  func testUnlink() throws {
    var didUnlink: Bool?
    var client: SFTP = .unimplemented
    client._unlink = {
      didUnlink = true
    }
    let unlink: Unlink = .sftp(client: client)
    try unlink()
    XCTAssertNotNil(didUnlink)
    XCTAssertTrue(didUnlink!)
  }
}
