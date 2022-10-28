import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class DropboxDownloadTests: XCTestCase {
  func testDownload() throws {
    var didFailWithError: Any?
    var didDownloadWithData: Data?
    var didDownloadWithPath: String?
    let mockPath = "MOCK_PATH"
    let mockData = "MOCK_DATA".data(using: .utf8)
    var client: Dropbox = .unimplemented
    client._download = { path, completion in
      didDownloadWithPath = path
      completion(.success(mockData))
    }
    let download: Download = .dropbox(
      path: mockPath,
      client: client
    )
    try download {
      switch $0 {
      case .success(let data):
        didDownloadWithData = data
      case .failure(let error):
        didFailWithError = error
      }
    }
    XCTAssertNil(didFailWithError)
    XCTAssertEqual(didDownloadWithPath, mockPath)
    XCTAssertEqual(didDownloadWithData, mockData)
  }
}
