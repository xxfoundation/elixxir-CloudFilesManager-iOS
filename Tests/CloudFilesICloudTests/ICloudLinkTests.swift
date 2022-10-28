import XCTest
import CloudFiles
@testable import CloudFilesICloud

final class ICloudLinkTests: XCTestCase {
  func testLink() throws {
    var didLink: Int = 0
    var client: ICloud = .unimplemented
    client._isLinked = { false }
    client._link = { didLink += 1 }
    let link: Link = .iCloud(client: client)
    try link(UIViewController()) { _ in }
    XCTAssertEqual(didLink, 1)
  }
}
