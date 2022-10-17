import XCTest
import CloudFiles
@testable import CloudFilesSFTP

final class SFTPIsLinkedTests: XCTestCase {
  func testIsLinkedWhenClientIsLinked() throws {
    var client: SFTP = .unimplemented
    client._isLinked = { true }
    let isLinked: IsLinked = .sftp(client: client)
    XCTAssertTrue(isLinked())
  }

  func testIsLinkedWhenClientIsNotLinked() throws {
    var client: SFTP = .unimplemented
    client._isLinked = { false }
    let isLinked: IsLinked = .sftp(client: client)
    XCTAssertFalse(isLinked())
  }
}
