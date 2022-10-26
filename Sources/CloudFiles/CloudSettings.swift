import Foundation

public struct CloudSettings: Equatable, Codable {
  public var wifiOnlyBackup: Bool
  public var automaticBackups: Bool
  public var enabledService: CloudService?
  public var backups: [CloudService: Fetch.Metadata]
  public var connectedServices: [CloudService: CloudFilesManager]

  public init(
    wifiOnlyBackup: Bool = false,
    automaticBackups: Bool = false,
    enabledService: CloudService? = nil,
    backups: [CloudService: Fetch.Metadata] = [:],
    connectedServices: [CloudService: CloudFilesManager] = [:]
  ) {
    self.wifiOnlyBackup = wifiOnlyBackup
    self.automaticBackups = automaticBackups
    self.enabledService = enabledService
    self.connectedServices = connectedServices
    self.backups = backups
  }

  public func toData() -> Data {
    (try? PropertyListEncoder().encode(self)) ?? Data()
  }

  public init(fromData data: Data?) {
    if let data = data, let settings = try? PropertyListDecoder().decode(CloudSettings.self, from: data) {
      self.init(
        wifiOnlyBackup: settings.wifiOnlyBackup,
        automaticBackups: settings.automaticBackups,
        enabledService: settings.enabledService,
        backups: settings.backups,
        connectedServices: settings.connectedServices
      )
    } else {
      self.init(
        wifiOnlyBackup: false,
        automaticBackups: true,
        enabledService: nil,
        backups: [:],
        connectedServices: [:]
      )
    }
  }
}
