import Foundation
import Zstd

if CommandLine.argc != 2 {
  print("wrong arguments")
  print("usage:")
  print("\(CommandLine.arguments[0]) FILE")
  exit(1)
}

let inFileURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outFileURL = inFileURL.appendingPathExtension("zst")

let inBuffer = try Data(contentsOf: inFileURL, options: [.uncached])
let outBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: Zstd.maximumCompressedSize(srcSize: inBuffer.count), alignment: MemoryLayout<UInt8>.alignment)
defer {
  outBuffer.deallocate()
}

let cSize = try Zstd.compress(src: inBuffer, dst: outBuffer, compressionLevel: 1)
print(String(format: "\(CommandLine.arguments[1]) : %6u -> %7u - \(outFileURL.path) ", inBuffer.count, cSize))
try Data(bytesNoCopy: outBuffer.baseAddress!, count: cSize, deallocator: .none).write(to: outFileURL)
