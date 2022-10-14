import XCTest
import CloudFiles
@testable import CloudFilesDrive

final class CloudFilesDriveDownloadTests: XCTestCase {
  private let mockFileName = "MOCK_FILE_NAME"
  private let mockData = "MOCK_DATA".data(using: .utf8)

  private var didFailWithError: Any?
  private var didDownloadWithData: Data?
  private var didDownloadWithFileName: String?
  private var client: CloudFilesDrive = .unimplemented
  private var manager: CloudFilesManager = .unimplemented

  override func tearDown() {
    didFailWithError = nil
    didDownloadWithData = nil
    didDownloadWithFileName = nil
    client = .unimplemented
    manager = .unimplemented
  }

  func testDownload() throws {
    client._download = { [weak self] fileName, completion in
      self?.didDownloadWithFileName = fileName
      completion(.success(self?.mockData))
    }
    manager.download = .drive(
      fileName: mockFileName,
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
    XCTAssertEqual(didDownloadWithData, mockData)
    XCTAssertEqual(didDownloadWithFileName, mockFileName)
  }
}
