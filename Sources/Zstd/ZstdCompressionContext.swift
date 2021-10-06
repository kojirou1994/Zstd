import CZstd

public final class ZstdCompressionContext {

  public let context: OpaquePointer

  public init() throws {
    guard let context = ZSTD_createCCtx() else {
      fatalError()
    }
    self.context = context
  }

  deinit {
    ZSTD_freeCCtx(context)
  }

  public func compress(src: UnsafeRawBufferPointer, dst: UnsafeMutableRawBufferPointer, compressionLevel: Int32) throws -> Int {
    try valueOrZstdError(ZSTD_compressCCtx(context, dst.baseAddress, dst.count, src.baseAddress, src.count, compressionLevel)).get()
  }

  public func compress(src: UnsafeRawBufferPointer, dst: UnsafeMutableRawBufferPointer, dict: UnsafeRawBufferPointer, compressionLevel: Int32) throws -> Int {
    try valueOrZstdError(ZSTD_compress_usingDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dict.baseAddress, dict.count, compressionLevel)).get()
  }

  public func compress(src: UnsafeRawBufferPointer, dst: UnsafeMutableRawBufferPointer, dict: ZstdCompressionDictionary) throws -> Int {
    try valueOrZstdError(ZSTD_compress_usingCDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dict.dic)).get()
  }

  public func compressStream2(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer, endOp: Zstd.EndDirective) throws -> Int {
    try valueOrZstdError(ZSTD_compressStream2(context, &outBuffer, &inBuffer, endOp)).get()
  }

  public func compress2(src: UnsafeRawBufferPointer, dst: UnsafeMutableRawBufferPointer) throws -> Int {
    try valueOrZstdError(ZSTD_compress2(context, dst.baseAddress, dst.count, src.baseAddress, src.count)).get()
  }

  public func set(param: Zstd.CompressionParameter, value: Int32) throws {
    try nothingOrZstdError(ZSTD_CCtx_setParameter(context, param, value))
  }

  public func set(param: Zstd.CompressionParameter, value: Bool) throws {
    try nothingOrZstdError(ZSTD_CCtx_setParameter(context, param, value ? 1 : 0))
  }

  public func set(pledgedSrcSize: UInt64) throws {
    try nothingOrZstdError(ZSTD_CCtx_setPledgedSrcSize(context, pledgedSrcSize))
  }

  public func reset(directive: Zstd.ResetDirective) throws {
    try nothingOrZstdError(ZSTD_CCtx_reset(context, directive))
  }

  public var size: Int {
    ZSTD_sizeof_CCtx(context)
  }
}
