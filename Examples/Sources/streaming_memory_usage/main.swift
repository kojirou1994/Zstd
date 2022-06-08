import Zstd
import Foundation

let maxTestedLevel: CInt = 12

print("\n Zstandard (v\(Zstd.version.string)) memory usage for streaming : \n")

var wLog: CUnsignedInt = 0
//if (argc > 1) {
//  const char* valStr = argv[1];
//  wLog = readU32FromChar(&valStr);
//}
let dataToCompress = Array("abcde".utf8)
var compressedData = [UInt8](repeating: 0, count: 128)
var decompressedData = [UInt8](repeating: 0, count: dataToCompress.count)

for compressionLevel in 1...maxTestedLevel {

  /* the ZSTD_CCtx_params structure is a way to save parameters and use
   * them across multiple contexts. We use them here so we can call the
   * function ZSTD_estimateCStreamSize_usingCCtxParams().
   */
  let cctxParams = try ZstdCompressionContext.Parameters()

  let context = try ZstdCompressionContext()
  /* Set the compression level. */
  try cctxParams.set(compressionLevel, for: .compressionLevel).get()
  /* Set the window log.
   * The value 0 means use the default window log, which is equivalent to
   * not setting it.
   */
  try cctxParams.set(wLog, for: .windowLog).get()
  /* Force the compressor to allocate the maximum memory size for a given
   * level by not providing the pledged source size, or calling
   * ZSTD_compressStream2() with ZSTD_e_end.
   */
  try context.set(parameters: cctxParams).get()

  let compressedSize: Int =
  try dataToCompress.withUnsafeBytes { src in
    try compressedData.withUnsafeMutableBytes { dst in
      var inBuffer = Zstd.InBuffer(src)
      var outBuffer = Zstd.OutBuffer(dst)

      _ = try context.compressStream(inBuffer: &inBuffer, outBuffer: &outBuffer).get()
      let remaining = try context.endStream(outBuffer: &outBuffer).get()
      precondition(remaining == 0, "Frame not flushed!")
      return outBuffer.pos
    }
  }

  let dcontext = try ZstdDecompressionContext()
  /* Set the maximum allowed window log.
   * The value 0 means use the default window log, which is equivalent to
   * not setting it.
   */
  try dcontext.set(wLog, for: .windowLogMax).get()

  /* forces decompressor to use maximum memory size, since the
   * decompressed size is not stored in the frame header.
   */

  try compressedData.withUnsafeBytes { src in
    try decompressedData.withUnsafeMutableBytes { dst in
      var inBuffer = Zstd.InBuffer(.init(rebasing: src.prefix(compressedSize)))
      var outBuffer = Zstd.OutBuffer(dst)

      let remaining = try dcontext.decompressStream(inBuffer: &inBuffer, outBuffer: &outBuffer).get()
      precondition(remaining == 0, "Frame not flushed!")
      precondition(outBuffer.pos == dataToCompress.count, "Bad decompression!")
    }
  }

  precondition(decompressedData == dataToCompress)

  let cstreamSize = context.size
  let cstreamEstimatedSize = try cctxParams.estimateCompressionStreamSize().get()
  let dstreamSize = dcontext.size
  let dstreamEstimatedSize = Zstd.decompressionStreamSize(frame: compressedData)

  precondition(cstreamSize <= cstreamEstimatedSize, "Compression mem (\(cstreamSize)) > estimated (\(cstreamEstimatedSize))")
  precondition(dstreamSize <= dstreamEstimatedSize, "Decompression mem (\(dstreamSize)) > estimated (\(dstreamEstimatedSize))")

  print(String(format: "Level %2i : Compression Mem = %5u KB (estimated : %5u KB) ; Decompression Mem = %4u KB (estimated : %5u KB)",
               compressionLevel,
               (cstreamSize>>10), (cstreamEstimatedSize>>10),
               (dstreamSize>>10), (dstreamEstimatedSize>>10)))
}

try FileHandle.standardError.write(contentsOf: Array("finished".utf8))
