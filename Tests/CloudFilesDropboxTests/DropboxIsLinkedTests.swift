import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class DropboxIsLinkedTests: XCTestCase {
  func testIsLinkedWhenClientIsLinked() throws {
    let mockAppKey = "MOCK_APP_KEY"
    var didCheckLinkStatusForAppKey: String?
    var client: Dropbox = .unimplemented
    client._isLinked = { appKey in
      didCheckLinkStatusForAppKey = appKey
      return true
    }
    let isLinked: IsLinked = .dropbox(appKey: mockAppKey, client: client)
    XCTAssertTrue(isLinked())
    XCTAssertEqual(didCheckLinkStatusForAppKey, mockAppKey)
  }

  func testIsLinkedWhenClientIsNotLinked() throws {
    let mockAppKey = "MOCK_APP_KEY"
    var didCheckIsLinkStatusForAppKey: String?
    var client: Dropbox = .unimplemented
    client._isLinked = { appKey in
      didCheckIsLinkStatusForAppKey = appKey
      return false
    }
    let isLinked: IsLinked = .dropbox(appKey: mockAppKey, client: client)
    XCTAssertFalse(isLinked())
    XCTAssertEqual(didCheckIsLinkStatusForAppKey, mockAppKey)
  }
}
