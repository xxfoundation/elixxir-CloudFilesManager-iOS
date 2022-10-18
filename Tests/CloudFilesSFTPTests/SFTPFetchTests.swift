import XCTest
import CloudFiles
@testable import CloudFilesSFTP

final class SFTPFetchTests: XCTestCase {
  func testFetch() throws {
    var didFailWithError: Any?
    var didFetchWithFileName: String?
    var didFetchMetadata: Fetch.Metadata?
    let mockFileName = "MOCK_FILE_NAME"
    let mockMetadata = Fetch.Metadata(
      size: 1234.5,
      lastModified: .distantPast
    )
    var client: SFTP = .unimplemented
    client._fetch = { fileName, completion in
      didFetchWithFileName = fileName
      completion(.success(mockMetadata))
    }
    let fetch: Fetch = .sftp(
      fileName: mockFileName,
      client: client
    )
    try fetch {
      switch $0 {
      case .success(let metadata):
        didFetchMetadata = metadata
      case .failure(let error):
        didFailWithError = error
      }
    }
    XCTAssertNil(didFailWithError)
    XCTAssertEqual(didFetchMetadata, mockMetadata)
    XCTAssertEqual(didFetchWithFileName, mockFileName)
  }
}
