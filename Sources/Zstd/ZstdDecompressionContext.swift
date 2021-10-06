import CZstd

public final class ZstdDecompressionContext {

  public let context: OpaquePointer

  public init() throws {
    guard let context = ZSTD_createDCtx() else {
      fatalError()
    }
    self.context = context
  }

  deinit {
    ZSTD_freeDCtx(context)
  }

  public func decompress(src: UnsafeRawBufferPointer, dst: UnsafeMutableRawBufferPointer) throws -> Int {
    try valueOrZstdError(ZSTD_decompressDCtx(context, dst.baseAddress, dst.count, src.baseAddress, src.count)).get()
  }

  public func decompress(src: UnsafeRawBufferPointer, dst: UnsafeMutableRawBufferPointer, dict: UnsafeRawBufferPointer) throws -> Int {
    try valueOrZstdError(ZSTD_decompress_usingDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dict.baseAddress, dict.count)).get()
  }

  public func decompress(src: UnsafeRawBufferPointer, dst: UnsafeMutableRawBufferPointer, dict: ZstdDecompressionDictionary) throws -> Int {
    try valueOrZstdError(ZSTD_decompress_usingDDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dict.dic)).get()
  }

  public func decompressStream(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer) throws -> Int {
    try valueOrZstdError(ZSTD_decompressStream(context, &outBuffer, &inBuffer)).get()
  }

  public func set(param: Zstd.DecompressionParameter, value: Int32) throws {
    try nothingOrZstdError(ZSTD_DCtx_setParameter(context, param, value))
  }

  public func set(param: Zstd.DecompressionParameter, value: Bool) throws {
    try nothingOrZstdError(ZSTD_DCtx_setParameter(context, param, value ? 1 : 0))
  }

  public func reset(directive: Zstd.ResetDirective) throws {
    try nothingOrZstdError(ZSTD_DCtx_reset(context, directive))
  }

  public var size: Int {
    ZSTD_sizeof_DCtx(context)
  }
}
