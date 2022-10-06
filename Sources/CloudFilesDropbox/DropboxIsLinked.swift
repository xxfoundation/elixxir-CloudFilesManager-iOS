import CloudFiles
import SwiftyDropbox

extension IsLinked {
  public static func dropbox() -> IsLinked {
    IsLinked {
      DropboxClientsManager.authorizedClient != nil
    }
  }
}
