import XCTest
import CloudFiles
@testable import CloudFilesDrive

final class DriveFetchTests: XCTestCase {
  func testFetch() throws {
    var didFailWithError: Any?
    var didFetchWithFileName: String?
    var didFetchMetadata: Fetch.Metadata?
    let mockedFileName = "FILE_NAME_FETCH"
    let mockedMetadata = Fetch.Metadata(
      size: 1234.5,
      lastModified: Date.distantPast
    )
    var client: Drive = .unimplemented
    client._fetch = { fileName, completion in
      didFetchWithFileName = fileName
      completion(.success(mockedMetadata))
    }
    let fetch: Fetch = .drive(
      client: client,
      fileName: mockedFileName
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
    XCTAssertEqual(didFetchMetadata, mockedMetadata)
    XCTAssertEqual(didFetchWithFileName, mockedFileName)
  }
}
