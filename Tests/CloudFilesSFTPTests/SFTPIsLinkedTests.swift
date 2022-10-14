import XCTest
import CloudFiles
@testable import CloudFilesSFTP

final class SFTPIsLinkedTests: XCTestCase {
  func testIsLinked() throws {
    var didRequestIsLinked: Bool?
    var client: SFTP = .unimplemented
    client._isLinked = {
      didRequestIsLinked = true
      return true
    }
    let isLinked: IsLinked = .sftp(client: client)
    XCTAssertEqual(isLinked(), didRequestIsLinked)
    XCTAssertNotNil(didRequestIsLinked)
  }
}
