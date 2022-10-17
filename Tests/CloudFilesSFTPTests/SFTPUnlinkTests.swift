import XCTest
import CloudFiles
@testable import CloudFilesSFTP

final class SFTPUnlinkTests: XCTestCase {
  func testUnlink() throws {
    var didUnlink: Int = 0
    var client: SFTP = .unimplemented
    client._unlink = { didUnlink += 1 }
    let unlink: Unlink = .sftp(client: client)
    try unlink()
    XCTAssertEqual(didUnlink, 1)
  }
}
