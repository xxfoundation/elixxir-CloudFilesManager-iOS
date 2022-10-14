import CloudFiles

extension Link {
  public static func iCloud(
    client: CloudFilesICloud = .live()
  ) -> Link {
    Link { _,_ in
      client.link()
    }
  }
}

extension IsLinked {
  public static func iCloud(
    client: CloudFilesICloud = .live()
  ) -> IsLinked {
    IsLinked {
      client.isLinked()
    }
  }
}

extension Unlink {
  public static func iCloud(
    client: CloudFilesICloud = .live()
  ) -> Unlink {
    Unlink {
      client.unlink()
    }
  }
}

extension Upload {
  public static func iCloud(
    fileName: String,
    client: CloudFilesICloud = .live()
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
  public static func iCloud(
    fileName: String,
    client: CloudFilesICloud = .live()
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
  public static func iCloud(
    fileName: String,
    client: CloudFilesICloud = .live()
  ) -> Download {
    Download {
      client.download(
        fileName: fileName,
        completion: $0
      )
    }
  }
}
