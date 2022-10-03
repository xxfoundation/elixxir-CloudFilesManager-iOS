// swift-tools-version: 5.7

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .unsafeFlags(
    [
      "-Xfrontend",
      "-debug-time-function-bodies",
      "-Xfrontend",
      "-debug-time-expression-type-checking",
    ],
    .when(configuration: .debug)
  ),
]

let package = Package(
  name: "XXMCloudProviders",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "SFTPFeature",
      targets: ["SFTPFeature"]
    ),
    .library(
      name: "DriveFeature",
      targets: ["DriveFeature"]
    ),
    .library(
      name: "ICloudFeature",
      targets: ["ICloudFeature"]
    ),
    .library(
      name: "DropboxFeature",
      targets: ["DropboxFeature"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/google/GoogleSignIn-iOS",
      .upToNextMajor(from: "6.1.0")
    ),
    .package(
      url: "https://github.com/dropbox/SwiftyDropbox.git",
      .upToNextMajor(from: "8.2.1")
    ),
    .package(
      url: "https://github.com/amosavian/FileProvider.git",
      .upToNextMajor(from: "0.26.0")
    ),
    .package(
      url: "https://github.com/darrarski/Shout.git",
      revision: "df5a662293f0ac15eeb4f2fd3ffd0c07b73d0de0"
    ),
    .package(
      url: "https://github.com/google/google-api-objectivec-client-for-rest",
      .upToNextMajor(from: "1.6.0")
    ),
  ],
  targets: [
    .target(
      name: "SFTPFeature",
      dependencies: [
        .product(
          name: "Shout",
          package: "Shout"
        )
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "SFTPFeatureTests",
      dependencies: [
        .target(
          name: "SFTPFeature"
        )
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ICloudFeature",
      dependencies: [
        .product(
          name: "FilesProvider",
          package: "FileProvider"
        )
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "ICloudFeatureTests",
      dependencies: [
        .target(
          name: "ICloudFeature"
        )
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "DropboxFeature",
      dependencies: [
        .product(
          name: "SwiftyDropbox",
          package: "SwiftyDropbox"
        )
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "DropboxFeatureTests",
      dependencies: [
        .target(
          name: "DropboxFeature"
        )
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "DriveFeature",
      dependencies: [
        .product(
          name: "GoogleSignIn",
          package: "GoogleSignIn-iOS"
        ),
        .product(
          name: "GoogleAPIClientForREST_Drive",
          package: "google-api-objectivec-client-for-rest"
        )
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "DriveFeatureTests",
      dependencies: [
        .target(
          name: "DriveFeature"
        )
      ],
      swiftSettings: swiftSettings
    )
  ]
)
