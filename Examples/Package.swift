// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "Examples",
  platforms: [
    .macOS(.v11),
  ],
  dependencies: [
    .package(path: "../"),
  ],
  targets: [
    .executableTarget(name: "streaming_memory_usage", dependencies: ["Zstd"]),
    .executableTarget(name: "simple_compression", dependencies: ["Zstd"]),
    .executableTarget(name: "simple_decompression", dependencies: ["Zstd"]),
    .executableTarget(name: "multiple_simple_compression", dependencies: ["Zstd"]),
    .executableTarget(name: "multiple_streaming_compression", dependencies: ["Zstd"]),
  ]
)
