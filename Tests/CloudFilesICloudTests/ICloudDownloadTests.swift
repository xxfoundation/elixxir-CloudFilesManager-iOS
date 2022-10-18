import XCTest
import CloudFiles
@testable import CloudFilesICloud

final class ICloudDownloadTests: XCTestCase {
  func testDownload() throws {
    var didFailWithError: Any?
    var didDownloadWithData: Data?
    var didDownloadWithFileName: String?
    let mockFileName = "MOCK_FILE_NAME"
    let mockData = "MOCK_DATA".data(using: .utf8)
    var client: ICloud = .unimplemented
    client._download = { fileName, completion in
      didDownloadWithFileName = fileName
      completion(.success(mockData!))
    }
    let download: Download  = .iCloud(
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
