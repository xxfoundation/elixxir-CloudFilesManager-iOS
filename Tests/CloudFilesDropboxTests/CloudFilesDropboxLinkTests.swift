import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class CloudFilesDropboxLinkTests: XCTestCase {
  private let mockAppKey = "MOCK_APP_KEY"

  private var didFailWithError: Any?
  private var didLinkWithAppKey: String?
  private var didLinkWithApplication: UIApplication?
  private var didLinkWithController: UIViewController?
  private var client: CloudFilesDropbox = .unimplemented
  private var manager: CloudFilesManager = .unimplemented

  override func tearDown() {
    didFailWithError = nil
    didLinkWithController = nil
    didLinkWithApplication = nil
    client = .unimplemented
    manager = .unimplemented
  }

  func testLink() throws {
    let mockController = UIViewController()
    client._link = { [weak self] appKey, controller, application in
      self?.didLinkWithAppKey = appKey
      self?.didLinkWithController = controller
      self?.didLinkWithApplication = application
    }
    manager.link = .dropbox(
      client: client,
      appKey: mockAppKey,
      application: UIApplication.shared
    )
    try manager.link(mockController) { [weak self] in
      switch $0 {
      case .success:
        break
      case .failure(let error):
        self?.didFailWithError = error
      }
    }
    XCTAssertNil(didFailWithError)
    XCTAssertEqual(didLinkWithAppKey, mockAppKey)
    XCTAssertEqual(didLinkWithController, mockController)
    XCTAssertEqual(didLinkWithApplication, UIApplication.shared)
  }
}

