// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "Zstd",
  products: [
    .library(name: "Zstd", targets: ["Zstd"]),
  ],
  dependencies: [
  ],
  targets: [
    .systemLibrary(
      name: "CZstd",
      pkgConfig: "libzstd"
    ),
    .target(
      name: "Zstd",
      dependencies: [
        "CZstd",
      ]
    ),
  ]
)
