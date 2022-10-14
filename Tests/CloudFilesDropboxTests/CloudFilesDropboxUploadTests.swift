import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class CloudFilesDropboxUploadTests: XCTestCase {
  private let mockPath = "MOCK_PATH"
  private let mockData = "MOCK_DATA".data(using: .utf8)
  private let mockMetadata = Upload.Metadata(
    size: 12345.6,
    lastModified: Date.distantFuture
  )

  private var didFailWithError: Any?
  private var didUploadWithData: Data?
  private var didUploadWithPath: String?
  private var didCompleteWithMetadata: Upload.Metadata?
  private var client: CloudFilesDropbox = .unimplemented
  private var manager: CloudFilesManager = .unimplemented

  override func tearDown() {
    didFailWithError = nil
    didUploadWithData = nil
    didUploadWithPath = nil
    client = .unimplemented
    manager = .unimplemented
  }

  func testUpload() throws {
    client._upload = { [weak self] path, data, completion in
      guard let self else { return }

      self.didUploadWithPath = path
      self.didUploadWithData = data
      completion(.success(self.mockMetadata))
    }
    manager.upload = .dropbox(
      path: mockPath,
      client: client
    )
    try manager.upload(mockData!) { [weak self] in
      switch $0 {
      case.success(let metadata):
        self?.didCompleteWithMetadata = metadata
      case .failure(let error):
        self?.didFailWithError = error
      }
    }
    XCTAssertNil(didFailWithError)
    XCTAssertEqual(didUploadWithPath, mockPath)
    XCTAssertEqual(didUploadWithData, mockData)
    XCTAssertEqual(didCompleteWithMetadata, mockMetadata)
  }
}
