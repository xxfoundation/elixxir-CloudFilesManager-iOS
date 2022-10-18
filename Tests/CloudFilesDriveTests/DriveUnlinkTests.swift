import XCTest
import CloudFiles
@testable import CloudFilesDrive

final class DriveUnlinkTests: XCTestCase {
  func testUnlink() throws {
    var didUnlink: Int = 0
    var client: Drive = .unimplemented
    client._unlink = { didUnlink += 1 }
    let unlink: Unlink = .drive(client: client)
    try unlink()
    XCTAssertEqual(didUnlink, 1)
  }
}
