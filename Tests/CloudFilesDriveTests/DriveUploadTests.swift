import XCTest
import CloudFiles
@testable import CloudFilesDrive

final class DriveUploadTests: XCTestCase {
  func testUpload() throws {
    var didFailWithError: Any?
    var didUploadWithData: Data?
    var didFetchWithFileName: String?
    var didUploadWithFileName: String?
    var didUploadWithMetadata: Upload.Metadata?
    let mockFileId = "MOCK_FILE_ID"
    let mockFileName = "MOCK_FILE_NAME"
    let mockData = "MOCK_DATA".data(using: .utf8)
    let mockUploadMetadata = Upload.Metadata(
      size: 12345.6,
      lastModified: .distantFuture
    )
    var client: Drive = .unimplemented
    client._restore = { completion in
      completion(.success(()))
    }
    client._fetch = { fileName, completion in
      didFetchWithFileName = fileName
      completion(.success(Fetch.Metadata(
        id: mockFileId,
        size: 12345.7,
        lastModified: .distantPast
      )))
    }
    client._upload = { fileId, fileName, data, completion in
      didUploadWithData = data
      didUploadWithFileName = fileName
      completion(.success(mockUploadMetadata))
    }
    let upload: Upload = .drive(
      fileName: mockFileName,
      client: client
    )
    try upload(mockData!) {
      switch $0 {
      case .success(let metadata):
        didUploadWithMetadata = metadata
      case .failure(let error):
        didFailWithError = error
      }
    }
    XCTAssertNil(didFailWithError)
    XCTAssertEqual(didUploadWithData, mockData)
    XCTAssertEqual(didFetchWithFileName, mockFileName)
    XCTAssertEqual(didUploadWithFileName, mockFileName)
    XCTAssertEqual(didUploadWithMetadata, mockUploadMetadata)
  }
}
