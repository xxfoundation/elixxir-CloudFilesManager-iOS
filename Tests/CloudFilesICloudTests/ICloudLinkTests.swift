import XCTest
import CloudFiles
@testable import CloudFilesICloud

// TODO:
/// This test should be refactored.
/// We are not calling the completion on its implementation
/// The operation signature doesn't make much sense since we
/// don't use the UIViewController, nor the completion closure.

final class ICloudLinkTests: XCTestCase {
  func testLink() throws {
    var didRequestToLink: Bool?
    var client: ICloud = .unimplemented
    client._link = {
      didRequestToLink = true
    }
    let link: Link = .iCloud(client: client)
    try link(UIViewController()) { _ in }
    XCTAssertNotNil(didRequestToLink)
    XCTAssertTrue(didRequestToLink!)
  }
}
