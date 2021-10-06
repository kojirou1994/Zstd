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

  public func compress<T: ContiguousBytes>(src: T, dst: UnsafeMutableRawBufferPointer, compressionLevel: Int32) throws -> Int {
    try valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_compressCCtx(context, dst.baseAddress, dst.count, src.baseAddress, src.count, compressionLevel)
      }
    }.get()
  }

  public func compress2<T: ContiguousBytes>(src: T, dst: UnsafeMutableRawBufferPointer) throws -> Int {
    try valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_compress2(context, dst.baseAddress, dst.count, src.baseAddress, src.count)
      }
    }.get()
  }

  public func compress<T: ContiguousBytes, D: ContiguousBytes>(src: T, dst: UnsafeMutableRawBufferPointer, dictionary: D, compressionLevel: Int32) throws -> Int {
    try valueOrZstdError {
      src.withUnsafeBytes { src in
        dictionary.withUnsafeBytes { dictionary in
          ZSTD_compress_usingDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dictionary.baseAddress, dictionary.count, compressionLevel)
        }
      }
    }.get()
  }

  public func compress<T: ContiguousBytes>(src: T, dst: UnsafeMutableRawBufferPointer, dict: ZstdCompressionDictionary) throws -> Int {
    try valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_compress_usingCDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dict.dic)
      }
    }.get()
  }

  public func compressStream(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer) throws -> Int {
    try valueOrZstdError {
      ZSTD_compressStream(context, &outBuffer, &inBuffer)
    }.get()
  }

  public func flushStream(outBuffer: inout Zstd.OutBuffer) throws -> Int {
    try valueOrZstdError {
      ZSTD_flushStream(context, &outBuffer)
    }.get()
  }

  public func endStream(outBuffer: inout Zstd.OutBuffer) throws -> Int {
    try valueOrZstdError{
      ZSTD_endStream(context, &outBuffer)
    }.get()
  }

  public func compressStream2(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer, endOp: Zstd.EndDirective) throws -> Int {
    try valueOrZstdError {
      ZSTD_compressStream2(context, &outBuffer, &inBuffer, endOp)
    }.get()
  }

  public func set<T: FixedWidthInteger>(param: Zstd.CompressionParameter, value: T) throws {
    try nothingOrZstdError {
      ZSTD_CCtx_setParameter(context, param, Int32(value))
    }
  }

  public func set(param: Zstd.CompressionParameter, value: Bool) throws {
    try nothingOrZstdError {
      ZSTD_CCtx_setParameter(context, param, value ? 1 : 0)
    }
  }

  public func set(pledgedSrcSize: UInt64) throws {
    try nothingOrZstdError {
      ZSTD_CCtx_setPledgedSrcSize(context, pledgedSrcSize)
    }
  }

  public func reset(directive: Zstd.ResetDirective) throws {
    try nothingOrZstdError {
      ZSTD_CCtx_reset(context, directive)
    }
  }

  public var size: Int {
    ZSTD_sizeof_CCtx(context)
  }
}
