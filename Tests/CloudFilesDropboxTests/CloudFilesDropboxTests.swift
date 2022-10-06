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
      _unlink: {
        self.isLinked = false
        self.didUnlink = true
      },
      _isLinked: {
        self.didGetLinkState = true
        return self.isLinked
      },
      _fetch: { path, completion in
        self.didFetchPath = path
      },
      _link: { appKey, controller, application in
        self.didLinkAppKey = appKey
        self.isLinked = true
      },
      _download: { path, completion in
        self.didDownloadPath = path
      },
      _upload: { path, input, completion in
        self.didUploadPath = path
      },
      _listFolder: { path, completion in
        self.didListPath = path
      },
      _createFolder: { path, completion in
        self.didCreateFolderPath = path
      }
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
