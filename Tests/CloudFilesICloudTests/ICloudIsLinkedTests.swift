import XCTest
import CloudFiles
@testable import CloudFilesICloud

final class ICloudIsLinkedTests: XCTestCase {
  func testIsLinked() throws {
    var didRequestIsLinked: Bool?
    var client: ICloud = .unimplemented
    client._isLinked = {
      didRequestIsLinked = true
      return true
    }
    let isLinked: IsLinked = .iCloud(client: client)
    XCTAssertEqual(isLinked(), didRequestIsLinked)
    XCTAssertNotNil(didRequestIsLinked)
  }
}
