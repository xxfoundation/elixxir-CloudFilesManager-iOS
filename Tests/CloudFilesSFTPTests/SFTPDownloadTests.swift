import XCTest
import CloudFiles
@testable import CloudFilesSFTP

final class SFTPDownloadTests: XCTestCase {
  func testDownload() throws {
    var didFailWithError: Any?
    var didDownloadWithData: Data?
    var didDownloadWithFileName: String?
    let mockFileName = "MOCK_FILE_NAME"
    let mockData = "MOCK_DATA".data(using: .utf8)
    var client: SFTP = .unimplemented
    client._download = { fileName, completion in
      didDownloadWithFileName = fileName
      completion(.success(mockData!))
    }
    let download: Download  = .sftp(
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
    XCTAssertEqual(didDownloadWithFileName, mockFileName)
  }
}
