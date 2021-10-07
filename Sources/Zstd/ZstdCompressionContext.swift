import CZstd

public final class ZstdCompressionContext {

  public let context: OpaquePointer

  public init() throws {
    context = try ZSTD_createCCtx().zstdUnwrap()
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

  public func set<T: FixedWidthInteger>(_ value: T, for param: Zstd.CompressionParameter) throws {
    try nothingOrZstdError {
      ZSTD_CCtx_setParameter(context, param, Int32(value))
    }
  }

  public func set<T: RawRepresentable>(_ value: T,  for param: Zstd.CompressionParameter) throws where T.RawValue: FixedWidthInteger {
    try set(value.rawValue, for: param)
  }

  public func set(_ value: Bool, for param: Zstd.CompressionParameter) throws {
    try set(value ? 1 as Int32 : 0, for: param)
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

public extension ZstdCompressionContext {
  func compressStreamAll(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer, endOp: Zstd.EndDirective, body: (UnsafeRawBufferPointer) throws -> Void) throws {
    repeat {
      outBuffer.pos = 0
      let remaining = try compressStream2(inBuffer: &inBuffer, outBuffer: &outBuffer, endOp: endOp)
      try body(.init(start: outBuffer.dst, count: outBuffer.pos))
      if endOp == .end ? remaining == 0 : inBuffer.isCompleted {
        return
      }
    } while true
  }
}
