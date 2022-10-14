import XCTest
import CloudFiles
@testable import CloudFilesDrive

final class DriveUnlinkTests: XCTestCase {
  func testUnlink() throws {
    var didUnlink: Bool?
    var client: Drive = .unimplemented
    client._unlink = {
      didUnlink = true
    }
    let unlink: Unlink = .drive(client: client)
    try unlink()
    XCTAssertNotNil(didUnlink)
    XCTAssertTrue(didUnlink!)
  }
}
