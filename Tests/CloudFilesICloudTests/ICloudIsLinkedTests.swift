import XCTest
import CloudFiles
@testable import CloudFilesICloud

final class ICloudIsLinkedTests: XCTestCase {
  func testIsLinkedWhenClientIsLinked() throws {
    var client: ICloud = .unimplemented
    client._isLinked = { true }
    let isLinked: IsLinked = .iCloud(client: client)
    XCTAssertTrue(isLinked())
  }

  func testIsLinkedWhenClientIsNotLinked() throws {
    var client: ICloud = .unimplemented
    client._isLinked = { false }
    let isLinked: IsLinked = .iCloud(client: client)
    XCTAssertFalse(isLinked())
  }
}
