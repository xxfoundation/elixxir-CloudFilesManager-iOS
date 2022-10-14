import XCTest
import CloudFiles
@testable import CloudFilesDropbox

final class CloudFilesDropboxFetchTests: XCTestCase {
  private let mockedPath = "PATH_FETCH"
  private let mockedMetadata = Fetch.Metadata(
    size: 1234.5,
    lastModified: Date.distantPast
  )

  private var didFailWithError: Any?
  private var didFetchWithPath: String?
  private var didFetchMetadata: Fetch.Metadata?
  private var client: CloudFilesDropbox = .unimplemented
  private var manager: CloudFilesManager = .unimplemented

  override func tearDown() {
    didFailWithError = nil
    didFetchMetadata = nil
    didFetchWithPath = nil
    client = .unimplemented
    manager = .unimplemented
  }

  func testFetch() throws {
    client._fetch = { [weak self] path, completion in
      self?.didFetchWithPath = path
      completion(.success(self?.mockedMetadata))
    }
    manager.fetch = .dropbox(path: mockedPath, client: client)
    try manager.fetch { [weak self] in
      switch $0 {
      case .success(let metadata):
        self?.didFetchMetadata = metadata
      case .failure(let error):
        self?.didFailWithError = error
      }
    }
    XCTAssertNil(didFailWithError)
    XCTAssertEqual(didFetchWithPath, mockedPath)
    XCTAssertEqual(didFetchMetadata, mockedMetadata)
  }

  func testFetchFailing() throws {
    client._fetch = { [weak self] path, completion in
      self?.didFetchWithPath = path
      completion(.failure(CloudFilesDropbox.Error.unknown))
    }
    manager.fetch = .dropbox(path: mockedPath, client: client)
    try manager.fetch { [weak self] in
      switch $0 {
      case .success(let metadata):
        self?.didFetchMetadata = metadata
      case .failure(let error):
        self?.didFailWithError = error
      }
    }
    XCTAssertNil(didFetchMetadata)
    XCTAssertNotNil(didFailWithError)
    XCTAssertEqual(didFetchWithPath, mockedPath)
  }
}
