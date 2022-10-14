import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class CloudFilesDropboxDownloadTests: XCTestCase {
  private let mockPath = "MOCK_PATH"
  private let mockData = "MOCK_DATA".data(using: .utf8)

  private var didFailWithError: Any?
  private var didDownloadWithData: Data?
  private var didDownloadWithPath: String?
  private var client: CloudFilesDropbox = .unimplemented
  private var manager: CloudFilesManager = .unimplemented

  override func tearDown() {
    didFailWithError = nil
    didDownloadWithData = nil
    didDownloadWithPath = nil
    client = .unimplemented
    manager = .unimplemented
  }

  func testDownload() throws {
    client._download = { [weak self] path, completion in
      self?.didDownloadWithPath = path
      completion(.success(self?.mockData))
    }
    manager.download = .dropbox(
      path: mockPath,
      client: client
    )
    try manager.download { [weak self] in
      switch $0 {
      case .success(let data):
        self?.didDownloadWithData = data
      case .failure(let error):
        self?.didFailWithError = error
      }
    }
    XCTAssertNil(didFailWithError)
    XCTAssertEqual(didDownloadWithPath, mockPath)
    XCTAssertEqual(didDownloadWithData, mockData)
  }
}
