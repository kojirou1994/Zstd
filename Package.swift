// swift-tools-version:5.4

import PackageDescription
import Foundation

let useSystemZstd: Bool
#if os(Linux)
useSystemZstd = true
#else
useSystemZstd = ProcessInfo.processInfo.environment["SYSTEM_ZSTD"] != nil
#endif

let cZstd: Target
let cZstdName = "CZstd"

let swiftZstd: Target = .target(
  name: "Zstd",
  dependencies: [
    .target(name: cZstdName),
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

if !useSystemZstd || ProcessInfo.processInfo.environment["SYSTEM_STATIC_ZSTD"] != nil {
  swiftZstd.cSettings = [.define("ZSTD_STATIC_LINKING_ONLY")]
} else {
  swiftZstd.exclude.append(contentsOf: ["StaticLinkingFeatures"])
}

let package = Package(
  name: "Zstd",
  products: [
    .library(name: cZstdName, targets: [cZstdName]),
    .library(name: swiftZstd.name, targets: [swiftZstd.name]),
  ],
  dependencies: [
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
