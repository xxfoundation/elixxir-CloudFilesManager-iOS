import Foundation

public struct CloudSettings: Equatable, Codable {
  public var wifiOnlyBackup: Bool
  public var automaticBackups: Bool
  public var enabledService: CloudService?

  public init(
    wifiOnlyBackup: Bool = false,
    automaticBackups: Bool = false,
    enabledService: CloudService? = nil
  ) {
    self.wifiOnlyBackup = wifiOnlyBackup
    self.enabledService = enabledService
    self.automaticBackups = automaticBackups
  }

  public func toData() -> Data {
    (try? PropertyListEncoder().encode(self)) ?? Data()
  }

  public init(fromData data: Data?) {
    if let data = data, let settings = try? PropertyListDecoder().decode(CloudSettings.self, from: data) {
      self.init(
        wifiOnlyBackup: settings.wifiOnlyBackup,
        automaticBackups: settings.automaticBackups,
        enabledService: settings.enabledService
      )
    } else {
      self.init(
        wifiOnlyBackup: false,
        automaticBackups: true,
        enabledService: nil
      )
    }
  }
}
