import XCTest
import Zstd

final class ZstdLinkTests: XCTestCase {
  func testConstants() throws {
    print(Zstd.version)
    print(Zstd.versionNumber)

    print(Zstd.compressionLevelRange)
    print(Zstd.defaultCompressionLevel)

    print("compressionInputBufferSize", Zstd.compressionInputBufferSize)
    print("compressionOutputBufferSize", Zstd.compressionOutputBufferSize)
    print("decompressionInputBufferSize", Zstd.decompressionInputBufferSize)
    print("decompressionOutputBufferSize", Zstd.decompressionOutputBufferSize)

    print(try Zstd.getBounds(param: .compressionLevel))
    print(try Zstd.getBounds(param: .nbWorkers))

  }
}
