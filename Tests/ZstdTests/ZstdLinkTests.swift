import XCTest
import Zstd

final class ZstdLinkTests: XCTestCase {
  func testConstants() throws {
    print(Zstd.version)
    print(Zstd.versionNumber)

    print(Zstd.compressionLevelRange)
    print(Zstd.defaultCompressionLevel)

    print(Zstd.recommendedInputBufferSize)
    print(Zstd.recommendedOutputBufferSize)

    print(try Zstd.getBounds(param: .compressionLevel))
    print(try Zstd.getBounds(param: .nbWorkers))

  }
}
