import Zstd
import Foundation

let maxTestedLevel = 12

print("\n Zstandard (v\(Zstd.version)) memory usage for streaming : \n")

var wLog: CUnsignedInt = 0
//if (argc > 1) {
//  const char* valStr = argv[1];
//  wLog = readU32FromChar(&valStr);
//}

#if STATIC_ZSTD
print(1)
#endif

for compressionLevel in 1...maxTestedLevel {

  let dataToCompress = Data("abcde".utf8)
  var compressedData = Data(repeating: 0, count: 128)
  var decompressedData = Data(repeating: 0, count: dataToCompress.count)
  /* the ZSTD_CCtx_params structure is a way to save parameters and use
   * them across multiple contexts. We use them here so we can call the
   * function ZSTD_estimateCStreamSize_usingCCtxParams().
   */
  let cctxParams = try ZstdCompressionContext.Parameters()

  let context = try ZstdCompressionContext()
  /* Set the compression level. */
  try cctxParams.set(compressionLevel, for: .compressionLevel )
  try cctxParams.set(4, for: .nbWorkers)
  /* Set the window log.
   * The value 0 means use the default window log, which is equivalent to
   * not setting it.
   */
  try cctxParams.set(wLog, for: .windowLog )
  /* Force the compressor to allocate the maximum memory size for a given
   * level by not providing the pledged source size, or calling
   * ZSTD_compressStream2() with ZSTD_e_end.
   */
  try context.set(parameters: cctxParams)
  
  let compressedSize: Int =
  try dataToCompress.withUnsafeBytes { src in
    try compressedData.withUnsafeMutableBytes { dst in
      var inBuffer = Zstd.InBuffer(src)
      var outBuffer = Zstd.OutBuffer(dst)

      _ = try context.compressStream(inBuffer: &inBuffer, outBuffer: &outBuffer)
      let remaining = try context.endStream(outBuffer: &outBuffer)
      precondition(remaining == 0, "Frame not flushed!")
      return outBuffer.pos
    }
  }

  let dcontext = try ZstdDecompressionContext()
  /* Set the maximum allowed window log.
   * The value 0 means use the default window log, which is equivalent to
   * not setting it.
   */
  try dcontext.set(wLog, for: .windowLogMax)

  /* forces decompressor to use maximum memory size, since the
   * decompressed size is not stored in the frame header.
   */

  try compressedData.withUnsafeBytes { src in
    try decompressedData.withUnsafeMutableBytes { dst in
      var inBuffer = Zstd.InBuffer(.init(rebasing: src.prefix(compressedSize)))
      var outBuffer = Zstd.OutBuffer(dst)

      let remaining = try dcontext.decompressStream(inBuffer: &inBuffer, outBuffer: &outBuffer)
      precondition(remaining == 0, "Frame not flushed!")
      precondition(outBuffer.pos == dataToCompress.count, "Bad decompression!")
    }
  }

  precondition(decompressedData == dataToCompress)

  let cstreamSize = context.size
  let cstreamEstimatedSize = ZstdEstimate.compressionStreamSize(cctxParams)
  let dstreamSize = dcontext.size
  let dstreamEstimatedSize = compressedData.withUnsafeBytes { ZstdEstimate.decompressionStreamSize(frame: $0) }

//  precondition(cstreamSize <= cstreamEstimatedSize, "Compression mem (\(cstreamSize)) > estimated (\(cstreamEstimatedSize))")
//  precondition(dstreamSize <= dstreamEstimatedSize, "Decompression mem (\(dstreamSize)) > estimated (\(dstreamEstimatedSize))")

  print(String(format: "Level %2i : Compression Mem = %5u KB (estimated : %5u KB) ; Decompression Mem = %4u KB (estimated : %5u KB)",
         compressionLevel,
        (cstreamSize>>10), (cstreamEstimatedSize>>10),
      (dstreamSize>>10), (dstreamEstimatedSize>>10)))
}
