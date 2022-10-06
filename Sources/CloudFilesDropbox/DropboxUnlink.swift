import CloudFiles
import SwiftyDropbox

extension Unlink {
  public static func dropbox() -> Unlink {
    Unlink {
      DropboxClientsManager.unlinkClients()
    }
  }
}
