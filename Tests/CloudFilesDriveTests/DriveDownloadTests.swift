import XCTest
import CloudFiles
@testable import CloudFilesDrive

final class DriveDownloadTests: XCTestCase {
  func testDownload() throws {
    var didFailWithError: Any?
    var didDownloadWithData: Data?
    var didFetchWithFileName: String?
    var didDownloadWithFileId: String?
    let mockFileName = "MOCK_FILE_NAME"
    let mockData = "MOCK_DATA".data(using: .utf8)
    let mockMetadata = Fetch.Metadata(
      id: "MOCK_FILE_ID",
      size: 1234.5,
      lastModified: .distantPast
    )
    var client: Drive = .unimplemented
    client._fetch = { fileName, completion in
      didFetchWithFileName = fileName
      completion(.success(mockMetadata))
    }
    client._download = { fileId, completion in
      didDownloadWithFileId = fileId
      completion(.success(mockData))
    }
    let download: Download = .drive(
      fileName: mockFileName,
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
    XCTAssertEqual(didDownloadWithData, mockData)
    XCTAssertEqual(didFetchWithFileName, mockFileName)
    XCTAssertEqual(didDownloadWithFileId, mockMetadata.id)
  }
}
