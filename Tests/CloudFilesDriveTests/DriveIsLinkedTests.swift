import XCTest
import CloudFiles
@testable import CloudFilesDrive

final class DriveIsLinkedTests: XCTestCase {
  func testIsLinked() throws {
    var didRequestIsLinked: Bool?
    var client: Drive = .unimplemented
    client._isLinked = {
      didRequestIsLinked = true
      return true
    }
    let isLinked: IsLinked = .drive(client: client)
    XCTAssertEqual(isLinked(), didRequestIsLinked)
    XCTAssertNotNil(didRequestIsLinked)
  }
}
