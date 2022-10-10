import CloudFiles

extension Link {
  public static func sftp(
    client: SFTPClient = .live
  ) -> Link {
    Link { _,_ in
      client.link()
    }
  }
}

extension IsLinked {
  public static func sftp(
    client: SFTPClient = .live
  ) -> IsLinked {
    IsLinked {
      client.isLinked()
    }
  }
}

extension Unlink {
  public static func sftp(
    client: SFTPClient = .live
  ) -> Unlink {
    Unlink {
      client.unlink()
    }
  }
}

extension Upload {
  public static func sftp(
    fileName: String,
    client: SFTPClient = .live
  ) -> Upload {
    Upload { data, completion in
      client.upload(
        input: data,
        fileName: fileName,
        completion: completion
      )
    }
  }
}

extension Fetch {
  public static func sftp(
    fileName: String,
    client: SFTPClient = .live
  ) -> Fetch {
    Fetch {
      client.fetch(
        fileName: fileName,
        completion: $0
      )
    }
  }
}

extension Download {
  public static func sftp(
    fileName: String,
    client: SFTPClient = .live
  ) -> Download {
    Download {
      client.download(
        fileName: fileName,
        completion: $0
      )
    }
  }
}
