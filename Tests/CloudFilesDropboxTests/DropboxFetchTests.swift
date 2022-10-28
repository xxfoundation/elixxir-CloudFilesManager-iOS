import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class DropboxFetchTests: XCTestCase {
  func testFetch() throws {
    var didFailWithError: Any?
    var didFetchWithPath: String?
    var didFetchMetadata: Fetch.Metadata?
    let mockPath = "PATH_FETCH"
    let mockMetadata = Fetch.Metadata(
      size: 1234.5,
      lastModified: Date.distantPast
    )
    var client: Dropbox = .unimplemented
    client._fetch = { path, completion in
      didFetchWithPath = path
      completion(.success(mockMetadata))
    }
    let fetch: Fetch = .dropbox(path: mockPath, client: client)
    try fetch {
      switch $0 {
      case .success(let metadata):
        didFetchMetadata = metadata
      case .failure(let error):
        didFailWithError = error
      }
    }
    XCTAssertNil(didFailWithError)
    XCTAssertEqual(didFetchWithPath, mockPath)
    XCTAssertEqual(didFetchMetadata, mockMetadata)
  }
}
