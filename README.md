# CloudFilesManager iOS

![Swift 5.7](https://img.shields.io/badge/swift-5.7-orange.svg)
![platform iOS](https://img.shields.io/badge/platform-iOS-blue.svg)

## 🚀 Quick Start

Add the following libraries as dependencies to your project using Swift Package Manager:
- CloudFilesSFTP
- CloudFilesDrive
- CloudFilesICloud
- CloudFilesDropbox

```swift
.package(
  url: "https://git.xx.network/elixxir/xxm-cloud-providers.git",
  .upToNextMajor(from: "1.0.0")
)
// ...
.product(name: "CloudFilesSFTP", package: "xxm-cloud-providers"),
.product(name: "CloudFilesDrive", package: "xxm-cloud-providers"),
.product(name: "CloudFilesICloud", package: "xxm-cloud-providers"),
.product(name: "CloudFilesDropbox", package: "xxm-cloud-providers"),
```
Import the dependencies for the services you want to use and set the managers:

```swift
import CloudFilesSFTP
import CloudFilesDrive
import CloudFilesICloud
import CloudFilesDropbox

let sftpManager = CloudFilesManager.sftp(
  host: "HOST",
  username: "USERNAME",
  password: "PASSWORD",
  fileName: "file_name.extension"
)
let driveManager = CloudFilesManager.drive(
  apiKey: "API_KEY",
  clientId: "CLIENT_ID",
  fileName: "file_name.extension"
)
let iCloudManager = CloudFilesManager.iCloud(
  fileName: "file_name.extension"
)
let dropboxManager = CloudFilesManager.dropbox(
  appKey: "APP_KEY",
  path: "/path/to_file.extension"
)
```
Perform any operations on any of the set services:
```swift
// Linking
//
try sftpManager.link(UIViewController()) {
  switch $0 {
    case .success:
      break
    case .failure(let error):
      print(error.localizedDescription)
  }
}

// Unlinking
//
try driveManager.unlink()

// Checking if isLinked
//
let isLinked = try driveManager.isLinked()

// Uploading:
//
if let data = "anything".data(using: .utf8) {
  try driveManager.upload(data) {
    switch $0 {
      case .success(let uploadedMetadata):
        print(uploadedMetadata)
      case .failure(let error):
        print(error.localizedDescription)
    }
  }
}

// Fetching
//
try dropboxManager.fetch {
  switch $0 {
    case .success(let fetchMetadata):
      print(fetchMetadata)
    case .failure(let error):
      print(error.localizedDescription)
  }
}

// Downloading
//
try iCloudManager.download {
  switch $0 {
    case .success(let downloadedData):
      print(downloadedData)
    case .failure(let error):
      print(error.localizedDescription)
  }
}
```
You can also use the static variables defined in the repository:
```swift
import CloudFiles

let linkedServices = CloudFilesManager.all.linkedServices()

CloudFilesManager.all.lastBackups {
  print($0) // [CloudService: Fetch.Metadata]
}
```
## 🛠 Development

Open `Package.swift` in Xcode (≥14).

### Project structure

```
xxm-cloud-providers [Swift Package]
├─ CloudFiles [Library]
├─ CloudFilesSFTP [Library]
├─ CloudFilesDrive [Library]
├─ CloudFilesICloud [Library]
└─ CloudFilesDropbox [Library]
```

### Build schemes

- Use `xxm-cloud-providers-Package` scheme to build and test the package.

## 📄 License

Copyright © 2022 xx network SEZC
