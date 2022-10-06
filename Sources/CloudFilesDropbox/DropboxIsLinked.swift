import CloudFiles

extension IsLinked {
  public static func dropbox(client: DropboxClient = .live) -> IsLinked {
    IsLinked {
      client.isLinked()
    }
  }
}
