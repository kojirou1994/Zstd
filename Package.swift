// swift-tools-version:5.4

import PackageDescription
import Foundation

let useSystemZstd: Bool
useSystemZstd = ProcessInfo.processInfo.environment["SYSTEM_ZSTD"] != nil

let cZstd: Target
let cZstdName = "CZstd"

let swiftZstd: Target = .target(
  name: "Zstd",
  dependencies: [
    .target(name: cZstdName),
    .product(name: "CUtility", package: "CUtility"),
  ]
)

if useSystemZstd {
  cZstd = .systemLibrary(
    name: cZstdName,
    path: "Sources/SystemZstd",
    pkgConfig: "libzstd"
  )
} else {
  cZstd = .target(
    name: cZstdName,
    path: "Sources/BundledZstd",
//    resources: [.copy("LICENSE")]
    exclude: [
      "LICENSE",
      "deprecated",
      "legacy",
    ],
    cSettings: [.define("ZSTD_MULTITHREAD", to: "1")],
    linkerSettings: [
      .linkedLibrary("pthread"),
    ]
  )
}

if !useSystemZstd {
  swiftZstd.cSettings = [.define("ZSTD_STATIC_LINKING_ONLY")]
  swiftZstd.swiftSettings = [.define("ZSTD_EXPERIMENTAL")]
}

let package = Package(
  name: "Zstd",
  products: [
    .library(name: cZstdName, targets: [cZstdName]),
    .library(name: swiftZstd.name, targets: [swiftZstd.name]),
  ],
  dependencies: [
    .package(url: "https://github.com/kojirou1994/CUtility.git", from: "0.1.0"),
  ],
  targets: [
    cZstd,
    swiftZstd,
    .testTarget(
      name: "ZstdTests",
      dependencies: ["Zstd"]),
  ],
  cLanguageStandard: .c11
)
