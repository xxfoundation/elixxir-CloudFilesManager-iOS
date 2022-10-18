import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class DropboxLinkTests: XCTestCase {
  func testLink() throws {
    var didFailWithError: Any?
    var didLinkWithAppKey: String?
    var didLinkWithApplication: UIApplication?
    var didLinkWithController: UIViewController?
    let mockAppKey = "MOCK_APP_KEY"
    let mockController = UIViewController()
    var client: Dropbox = .unimplemented
    client._link = { appKey, controller, application in
      didLinkWithAppKey = appKey
      didLinkWithController = controller
      didLinkWithApplication = application
    }
    let link: Link = .dropbox(
      client: client,
      appKey: mockAppKey,
      application: .shared
    )
    try link(mockController) {
      switch $0 {
      case .success:
        break
      case .failure(let error):
        didFailWithError = error
      }
    }
    XCTAssertNil(didFailWithError)
    XCTAssertEqual(didLinkWithAppKey, mockAppKey)
    XCTAssertEqual(didLinkWithController, mockController)
    XCTAssertEqual(didLinkWithApplication, UIApplication.shared)
  }
}

