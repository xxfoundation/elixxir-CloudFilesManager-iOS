import XCTest
import CloudFiles
@testable import CloudFilesSFTP

final class SFTPLinkTests: XCTestCase {
  func testLink() throws {
    var didFailWithError: Any?
    var didLinkWithHost: String?
    var didLinkWithUsername: String?
    var didLinkWithPassword: String?
    let mockHost = "MOCK_HOST"
    let mockUsername = "MOCK_USERNAME"
    let mockPassword = "MOCK_PASSWORD"
    var client: SFTP = .unimplemented
    client._link = { host, username, password, completion in
      didLinkWithHost = host
      didLinkWithUsername = username
      didLinkWithPassword = password
      completion(.success(()))
    }
    let link: Link = .sftp(
      host: mockHost,
      username: mockUsername,
      password: mockPassword,
      client: client
    )
    try link(UIViewController()) {
      switch $0 {
      case .success:
        break
      case .failure(let error):
        didFailWithError = error
      }
    }
    XCTAssertNil(didFailWithError)
    XCTAssertEqual(didLinkWithHost, mockHost)
    XCTAssertEqual(didLinkWithUsername, mockUsername)
    XCTAssertEqual(didLinkWithPassword, mockPassword)
  }
}
