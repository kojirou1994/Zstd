import Foundation
import Zstd

if CommandLine.argc != 2 {
  print("wrong arguments")
  print("usage:")
  print("\(CommandLine.arguments[0]) FILE")
  exit(1)
}

let inFile = CommandLine.arguments[1]
let inFileURL = URL(fileURLWithPath: inFile)

let inBuffer = try Data(contentsOf: inFileURL, options: [.uncached])
/* Read the content size from the frame header. For simplicity we require
 * that it is always present. By default, zstd will write the content size
 * in the header when it is known. If you can't guarantee that the frame
 * content size is always written into the header, either use streaming
 * decompression, or ZSTD_decompressBound().
 */
let rSize = try Zstd.getFrameContentSize(src: inBuffer)

precondition(rSize != Zstd.contentSizeError, "\(inFile): not compressed by zstd!")
precondition(rSize != Zstd.contentSizeUnknown, "\(inFile): original size unknown!")

let outBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: Int(rSize), alignment: MemoryLayout<UInt8>.alignment)
defer {
  outBuffer.deallocate()
}
/* Decompress.
 * If you are doing many decompressions, you may want to reuse the context
 * and use ZSTD_decompressDCtx(). If you want to set advanced parameters,
 * use ZSTD_DCtx_setParameter().
 */
let dSize = try Zstd.decompress(src: inBuffer, dst: outBuffer)
precondition(rSize == dSize, "Impossible because zstd will check this condition!")

print(String(format: "\(inFile) : %6u -> %7u ", inBuffer.count, rSize))

print("\(inFile) correctly decoded (in memory). ")
