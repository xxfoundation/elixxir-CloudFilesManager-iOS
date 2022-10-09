public struct CloudFilesManager {
  public var link: Link
  public var fetch: Fetch
  public var upload: Upload
  public var unlink: Unlink
  public var enable: Enable
  public var disable: Disable
  public var download: Download
  public var isLinked: IsLinked
  public var isEnabled: IsEnabled

  public init(
    link: Link = .unimplemented,
    fetch: Fetch = .unimplemented,
    upload: Upload = .unimplemented,
    unlink: Unlink = .unimplemented,
    enable: Enable = .unimplemented,
    disable: Disable = .unimplemented,
    download: Download = .unimplemented,
    isLinked: IsLinked = .unimplemented,
    isEnabled: IsEnabled = .unimplemented
  ) {
    self.link = link
    self.fetch = fetch
    self.upload = upload
    self.unlink = unlink
    self.enable = enable
    self.disable = disable
    self.download = download
    self.isLinked = isLinked
    self.isEnabled = isEnabled
  }
}
