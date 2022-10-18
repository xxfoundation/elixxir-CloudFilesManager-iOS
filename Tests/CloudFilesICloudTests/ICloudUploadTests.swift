import XCTest
import CloudFiles
@testable import CloudFilesICloud

final class ICloudUploadTests: XCTestCase {
  func testUpload() throws {
    var didFailWithError: Any?
    var didUploadWithData: Data?
    var didUploadWithFileName: String?
    var didCompleteWithMetadata: Upload.Metadata?
    let mockFileName = "MOCK_FILE_NAME"
    let mockData = "MOCK_DATA".data(using: .utf8)
    let mockMetadata = Upload.Metadata(
      size: 12345.6,
      lastModified: Date.distantFuture
    )
    var client: ICloud = .unimplemented
    client._upload = { fileName, data, completion in
      didUploadWithData = data
      didUploadWithFileName = fileName
      completion(.success(mockMetadata))
    }
    let upload: Upload = .iCloud(
      fileName: mockFileName,
      client: client
    )
    try upload(mockData!) {
      switch $0 {
      case.success(let metadata):
        didCompleteWithMetadata = metadata
      case .failure(let error):
        didFailWithError = error
      }
    }
    XCTAssertNil(didFailWithError)
    XCTAssertEqual(didUploadWithData, mockData)
    XCTAssertEqual(didUploadWithFileName, mockFileName)
    XCTAssertEqual(didCompleteWithMetadata, mockMetadata)

  }
}
