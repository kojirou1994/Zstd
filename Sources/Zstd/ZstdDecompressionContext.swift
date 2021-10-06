import CZstd

public final class ZstdDecompressionContext {

  public let context: OpaquePointer

  public init() throws {
    context = try ZSTD_createDCtx().zstdUnwrap()
  }

  deinit {
    ZSTD_freeDCtx(context)
  }

  public func decompress<T: ContiguousBytes>(src: T, dst: UnsafeMutableRawBufferPointer) throws -> Int {
    try valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_decompressDCtx(context, dst.baseAddress, dst.count, src.baseAddress, src.count)
      }
    }.get()
  }

  public func decompress<T: ContiguousBytes, D: ContiguousBytes>(src: T, dst: UnsafeMutableRawBufferPointer, dictionary: D) throws -> Int {
    try valueOrZstdError {
      src.withUnsafeBytes { src in
        dictionary.withUnsafeBytes { dictionary in
          ZSTD_decompress_usingDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dictionary.baseAddress, dictionary.count)
        }
      }
    }.get()
  }

  public func decompress<T: ContiguousBytes>(src: T, dst: UnsafeMutableRawBufferPointer, dictionary: ZstdDecompressionDictionary) throws -> Int {
    try valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_decompress_usingDDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dictionary.dic)
      }
    }.get()
  }

  public func decompressStream(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer) throws -> Int {
    try valueOrZstdError {
      ZSTD_decompressStream(context, &outBuffer, &inBuffer)
    }.get()
  }

  public func set<T: FixedWidthInteger>(param: Zstd.DecompressionParameter, value: T) throws {
    try nothingOrZstdError {
      ZSTD_DCtx_setParameter(context, param, Int32(value))
    }
  }

  public func set<T: RawRepresentable>(param: Zstd.DecompressionParameter, value: T) throws where T.RawValue: FixedWidthInteger {
    try set(param: param, value: value.rawValue)
  }

  public func set(param: Zstd.DecompressionParameter, value: Bool) throws {
    try nothingOrZstdError {
      ZSTD_DCtx_setParameter(context, param, value ? 1 : 0)
    }
  }

  public func reset(directive: Zstd.ResetDirective) throws {
    try nothingOrZstdError {
      ZSTD_DCtx_reset(context, directive)
    }
  }

  public var size: Int {
    ZSTD_sizeof_DCtx(context)
  }
}
