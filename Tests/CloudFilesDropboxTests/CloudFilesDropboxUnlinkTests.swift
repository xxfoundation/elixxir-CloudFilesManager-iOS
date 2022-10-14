import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class CloudFilesDropboxUnlinkTests: XCTestCase {
  private var didUnlink: Bool?
  private var client: CloudFilesDropbox = .unimplemented
  private var manager: CloudFilesManager = .unimplemented

  override func tearDown() {
    didUnlink = nil
    client = .unimplemented
    manager = .unimplemented
  }

  func testUnlink() throws {
    client._unlink = { [weak self] in
      self?.didUnlink = true
    }
    manager.unlink = .dropbox(client: client)
    try manager.unlink()
    XCTAssertNotNil(didUnlink)
    XCTAssertTrue(didUnlink!)
  }
}

