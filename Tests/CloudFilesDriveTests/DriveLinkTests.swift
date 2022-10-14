import XCTest
import CloudFiles
@testable import CloudFilesDrive

final class DriveLinkTests: XCTestCase {
  func testLink() throws {
    var didFailWithError: Any?
    var didSignInWithApiKey: String?
    var didSignInWithClientId: String?
    var didSignInWithController: UIViewController?
    var didAuthorizeWithController: UIViewController?
    let mockApiKey = "MOCK_API_KEY"
    let mockClientId = "MOCK_CLIENT_ID"
    let mockController = UIViewController()
    var client: Drive = .unimplemented
    client._signIn = { apiKey, clientId, controller, completion in
      didSignInWithApiKey = apiKey
      didSignInWithClientId = clientId
      didSignInWithController = controller
      completion(.success(()))
    }
    client._authorize = { controller, completion in
      didAuthorizeWithController = controller
      completion(.success(()))
    }
    let link: Link = .drive(
      client: client,
      apiKey: mockApiKey,
      clientId: mockClientId
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
    XCTAssertEqual(didSignInWithApiKey, mockApiKey)
    XCTAssertEqual(didSignInWithClientId, mockClientId)
    XCTAssertEqual(didSignInWithController, mockController)
    XCTAssertEqual(didAuthorizeWithController, mockController)
  }
}
