import CloudFiles

extension Link {
  public static func iCloud(
    client: ICloud = .live()
  ) -> Link {
    Link { _, completion in
      guard !client.isLinked() else {
        completion(.success(()))
        return
      }
      client.link()
    }
  }
}

extension IsLinked {
  public static func iCloud(
    client: ICloud = .live()
  ) -> IsLinked {
    IsLinked {
      client.isLinked()
    }
  }
}

extension Unlink {
  public static func iCloud(
    client: ICloud = .live()
  ) -> Unlink {
    Unlink {
      client.unlink()
    }
  }
}

extension Upload {
  public static func iCloud(
    fileName: String,
    client: ICloud = .live()
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
    client: ICloud = .live()
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
    client: ICloud = .live()
  ) -> Download {
    Download {
      client.download(
        fileName: fileName,
        completion: $0
      )
    }
  }
}
