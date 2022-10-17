import XCTest
import CloudFiles
@testable import CloudFilesDrive

final class DriveIsLinkedTests: XCTestCase {
  func testIsLinkedWhenClientIsLinked() throws {
    var client: Drive = .unimplemented
    client._isLinked = { true }
    let isLinked: IsLinked = .drive(client: client)
    XCTAssertTrue(isLinked())
  }

  func testIsLinkedWhenClientIsNotLinked() throws {
    var client: Drive = .unimplemented
    client._isLinked = { false }
    let isLinked: IsLinked = .drive(client: client)
    XCTAssertFalse(isLinked())
  }
}
