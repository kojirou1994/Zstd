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

let zstd: Target = .target(
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
    exclude: ["LICENSE"]
  )
}

if !useSystemZstd || ProcessInfo.processInfo.environment["SYSTEM_STATIC_ZSTD"] != nil {
  zstd.cSettings = [.define("ZSTD_STATIC_LINKING_ONLY")]
} else {
  zstd.exclude.append(contentsOf: ["ZstdCompressionParameters.swift"])
}

let package = Package(
  name: "Zstd",
  products: [
    .library(name: "Zstd", targets: ["Zstd"]),
  ],
  dependencies: [
  ],
  targets: [
    cZstd,
    zstd,
    .testTarget(
      name: "ZstdTests",
      dependencies: ["Zstd"]),
  ]
)
