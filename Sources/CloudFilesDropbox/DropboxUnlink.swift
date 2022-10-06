import CloudFiles

extension Unlink {
  public static func dropbox(client: DropboxClient = .live) -> Unlink {
    Unlink {
      client.unlink()
    }
  }
}
