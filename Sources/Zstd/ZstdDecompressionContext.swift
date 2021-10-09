import CZstd

public final class ZstdDecompressionContext {

  internal let context: OpaquePointer

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
    }
  }

  public func decompress<T: ContiguousBytes, D: ContiguousBytes>(src: T, dst: UnsafeMutableRawBufferPointer, dictionary: D) throws -> Int {
    try valueOrZstdError {
      src.withUnsafeBytes { src in
        dictionary.withUnsafeBytes { dictionary in
          ZSTD_decompress_usingDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dictionary.baseAddress, dictionary.count)
        }
      }
    }
  }

  public func decompress<T: ContiguousBytes>(src: T, dst: UnsafeMutableRawBufferPointer, dictionary: ZstdDecompressionDictionary) throws -> Int {
    try valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_decompress_usingDDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dictionary.dic)
      }
    }
  }

  public func decompressStream(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer) throws -> Int {
    try valueOrZstdError {
      ZSTD_decompressStream(context, &outBuffer, &inBuffer)
    }
  }

  public func set<T: FixedWidthInteger>(_ value: T, for param: Zstd.DecompressionParameter) throws {
    try nothingOrZstdError {
      ZSTD_DCtx_setParameter(context, param, Int32(value))
    }
  }

  public func set<T: RawRepresentable>(_ value: T,  for param: Zstd.DecompressionParameter) throws where T.RawValue: FixedWidthInteger {
    try set(value.rawValue, for: param)
  }

  public func set(_ value: Bool, for param: Zstd.DecompressionParameter) throws {
    try set(value ? 1 as Int32 : 0, for: param)
  }

  public func reset(directive: Zstd.ResetDirective) throws {
    try nothingOrZstdError {
      ZSTD_DCtx_reset(context, directive)
    }
  }

  private var referencedDictionary: ZstdDecompressionDictionary?

  public func load<B: ContiguousBytes>(dictionary: B) throws {
    try nothingOrZstdError {
      dictionary.withUnsafeBytes { buffer in
        ZSTD_DCtx_loadDictionary(context, buffer.baseAddress, buffer.count)
      }
    }
    referencedDictionary = nil
  }

  public func ref(dictionary: ZstdDecompressionDictionary) throws {
    try nothingOrZstdError {
      ZSTD_DCtx_refDDict(context, dictionary.dic)
    }
    referencedDictionary = dictionary
  }

  public func ref(prefix: UnsafeRawBufferPointer) throws {
    try nothingOrZstdError {
      ZSTD_DCtx_refPrefix(context, prefix.baseAddress, prefix.count)
    }
    referencedDictionary = nil
  }

  public func unloadDictionary() throws {
    try nothingOrZstdError {
      ZSTD_DCtx_refDDict(context, nil)
    }
    referencedDictionary = nil
  }

  public var size: Int {
    ZSTD_sizeof_DCtx(context)
  }
}

// MARK: Helper
public extension ZstdDecompressionContext {
  func decompressStreamAll(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer, body: (UnsafeRawBufferPointer) throws -> Void) throws {
    while true {
      outBuffer.pos = 0
      let remaining = try decompressStream(inBuffer: &inBuffer, outBuffer: &outBuffer)
      try body(.init(start: outBuffer.dst, count: outBuffer.pos))
      if inBuffer.isCompleted, remaining == 0 {
        return
      }
    }
  }
}

// MARK: Experimental APIs
#if ZSTD_EXPERIMENTAL
public extension ZstdDecompressionContext {
  func value(for param: Zstd.DecompressionParameter) throws -> Int32 {
    var r: Int32 = 0
    try nothingOrZstdError {
      ZSTD_DCtx_getParameter(context, param, &r)
    }
    return r
  }
}
#endif
