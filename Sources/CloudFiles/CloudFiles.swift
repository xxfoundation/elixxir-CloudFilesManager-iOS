import Foundation

import CloudFilesSFTP
import CloudFilesDrive
import CloudFilesICloud
import CloudFilesDropbox

public typealias CloudFileDownloadClosure = (Result<Data?, Error>) -> Void

public struct CloudFilesManager {
  var linkService: (CloudFileService) throws -> Void
  var unlinkService: () throws -> Void

  var enableService: (CloudFileService) throws -> Void
  var disableService: () throws -> Void
  var fetchLastMetadata: () throws -> CloudFileMetadata?

  var upload: (URL) throws -> Void
  var download: (@escaping CloudFileDownloadClosure) -> Void
}
