import CloudFiles

extension Download {
  public static func dropbox(
    path: String,
    client: DropboxClient = .live
  ) -> Download {
    Download {
      client.download(
        path: path,
        completion: $0
      )
    }
  }
}
