import XCTest
@testable import CloudFilesDropbox

final class CloudFilesDropboxTests: XCTestCase {
  var sut: DropboxClient!

  var isLinked = false
  var didUnlink = false
  var didListPath: String?
  var didFetchPath: String?
  var didLinkAppKey: String?
  var didUploadPath: String?
  var didDownloadPath: String?
  var didGetLinkState = false
  var didCreateFolderPath: String?

  override func setUp() {
    sut = .init(
      _unlink: {},
      _isLinked: { false },
      _fetch: { _,_ in },
      _link: { _,_,_ in },
      _download: { _,_ in },
      _upload: { _,_,_ in }
    )
  }

  override func tearDown() {
    isLinked = false
    didUnlink = false
    didListPath = nil
    didFetchPath = nil
    didLinkAppKey = nil
    didUploadPath = nil
    didDownloadPath = nil
    didGetLinkState = false
    didCreateFolderPath = nil
  }

  func testLinkingAndUnlinking() {
    XCTAssertFalse(sut.isLinked())
    XCTAssertTrue(didGetLinkState)

    let appKey = "ABCD"
    sut.link(
      appKey: appKey,
      controller: UIViewController(),
      application: .shared
    )
    XCTAssertEqual(appKey, didLinkAppKey)
    XCTAssertTrue(sut.isLinked())

    sut.unlink()
    XCTAssertTrue(didUnlink)
    XCTAssertFalse(sut.isLinked())
  }
}
