import CloudFiles

extension Unlink {
  public static func drive(
    client: DriveClient = .live()
  ) -> Unlink {
    Unlink {
      client.signOut()
    }
  }
}
