import CloudFiles

extension IsLinked {
  public static func drive(client: DriveClient = .live()) -> IsLinked {
    IsLinked {
      client.isLinked()
    }
  }
}
