import XCTest
import CloudFiles
@testable import CloudFilesDrive

final class CloudFilesDriveDownloadTests: XCTestCase {
  private let mockFileName = "MOCK_FILE_NAME"
  private let mockData = "MOCK_DATA".data(using: .utf8)
  private let mockMetadata = Fetch.Metadata(
    id: "MOCK_FILE_ID",
    size: 1234.5,
    lastModified: .distantPast
  )

  private var didFailWithError: Any?
  private var didDownloadWithData: Data?
  private var didFetchWithFileName: String?
  private var didDownloadWithFileId: String?

  private var client: CloudFilesDrive = .unimplemented
  private var manager: CloudFilesManager = .unimplemented

  override func tearDown() {
    didFailWithError = nil
    didDownloadWithData = nil
    didFetchWithFileName = nil
    didDownloadWithFileId = nil

    client = .unimplemented
    manager = .unimplemented
  }

  func testDownload() throws {
    client._fetch = { [weak self] fileName, completion in
      self?.didFetchWithFileName = fileName
      completion(.success(self?.mockMetadata))
    }
    client._download = { [weak self] fileId, completion in
      self?.didDownloadWithFileId = fileId
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
    XCTAssertEqual(didFetchWithFileName, mockFileName)
    XCTAssertEqual(didDownloadWithFileId, mockMetadata.id)
  }
}
