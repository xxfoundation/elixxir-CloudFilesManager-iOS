import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class DropboxUploadTests: XCTestCase {
  func testUpload() throws {
    var didFailWithError: Any?
    var didUploadWithData: Data?
    var didUploadWithPath: String?
    var didCompleteWithMetadata: Upload.Metadata?
    let mockPath = "MOCK_PATH"
    let mockData = "MOCK_DATA".data(using: .utf8)
    let mockMetadata = Upload.Metadata(
      size: 12345.6,
      lastModified: Date.distantFuture
    )
    var client: Dropbox = .unimplemented
    client._upload = { path, data, completion in
      didUploadWithPath = path
      didUploadWithData = data
      completion(.success(mockMetadata))
    }
    let upload: Upload = .dropbox(
      path: mockPath,
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
    XCTAssertEqual(didUploadWithPath, mockPath)
    XCTAssertEqual(didUploadWithData, mockData)
    XCTAssertEqual(didCompleteWithMetadata, mockMetadata)
  }
}
