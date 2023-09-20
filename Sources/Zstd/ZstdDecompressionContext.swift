import CZstd

public struct ZstdDecompressionContext: ~Copyable {

  @usableFromInline
  internal let context: OpaquePointer

  @inlinable
  @_alwaysEmitIntoClient
  public init() throws {
    context = try ZSTD_createDCtx().zstdUnwrap()
  }

  @inlinable
  @_alwaysEmitIntoClient
  deinit {
    ZSTD_freeDCtx(context)
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func decompress(src: any ContiguousBytes, dst: UnsafeMutableRawBufferPointer) -> Result<Int, ZstdError> {
    valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_decompressDCtx(context, dst.baseAddress, dst.count, src.baseAddress, src.count)
      }
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func decompress(src: any ContiguousBytes, dst: UnsafeMutableRawBufferPointer, dictionary: any ContiguousBytes) -> Result<Int, ZstdError> {
    valueOrZstdError {
      src.withUnsafeBytes { src in
        dictionary.withUnsafeBytes { dictionary in
          ZSTD_decompress_usingDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dictionary.baseAddress, dictionary.count)
        }
      }
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func decompress(src: any ContiguousBytes, dst: UnsafeMutableRawBufferPointer, dictionary: ZstdDecompressionDictionary) -> Result<Int, ZstdError> {
    valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_decompress_usingDDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dictionary.op)
      }
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func decompressStream(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer) -> Result<Int, ZstdError> {
    valueOrZstdError {
      ZSTD_decompressStream(context, &outBuffer, &inBuffer)
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func set<T: FixedWidthInteger>(_ value: T, for param: Zstd.DecompressionParameter) -> Result<Void, ZstdError> {
    nothingOrZstdError {
      ZSTD_DCtx_setParameter(context, param, Int32(value))
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func set<T: RawRepresentable>(_ value: T,  for param: Zstd.DecompressionParameter) -> Result<Void, ZstdError> where T.RawValue: FixedWidthInteger {
    set(value.rawValue, for: param)
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func set(_ value: Bool, for param: Zstd.DecompressionParameter) -> Result<Void, ZstdError> {
    set(value ? 1 as Int32 : 0, for: param)
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func reset(directive: Zstd.ResetDirective) -> Result<Void, ZstdError> {
    nothingOrZstdError {
      ZSTD_DCtx_reset(context, directive)
    }
  }

  @usableFromInline
  internal var referencedDictionary: ZstdDecompressionDictionary?

  @inlinable
  @_alwaysEmitIntoClient
  public mutating func load(dictionary: any ContiguousBytes) -> Result<Void, ZstdError> {
    nothingOrZstdError {
      dictionary.withUnsafeBytes { buffer in
        ZSTD_DCtx_loadDictionary(context, buffer.baseAddress, buffer.count)
      }
    }
    .map {
      referencedDictionary = nil
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public mutating func ref(dictionary: ZstdDecompressionDictionary) -> Result<Void, ZstdError> {
    nothingOrZstdError {
      ZSTD_DCtx_refDDict(context, dictionary.op)
    }
    .map {
      referencedDictionary = nil
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public mutating func ref(prefix: UnsafeRawBufferPointer) -> Result<Void, ZstdError> {
    nothingOrZstdError {
      ZSTD_DCtx_refPrefix(context, prefix.baseAddress, prefix.count)
    }
    .map {
      referencedDictionary = nil
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public mutating func unloadDictionary() -> Result<Void, ZstdError> {
    nothingOrZstdError {
      ZSTD_DCtx_refDDict(context, nil)
    }
    .map {
      referencedDictionary = nil
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public var size: Int {
    ZSTD_sizeof_DCtx(context)
  }
}

// MARK: Helper
public extension ZstdDecompressionContext {
  func decompressStreamAll(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer, body: (UnsafeRawBufferPointer) throws -> Void) throws {
    while true {
      outBuffer.pos = 0
      let remaining = try decompressStream(inBuffer: &inBuffer, outBuffer: &outBuffer).get()
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
  func value(for param: Zstd.DecompressionParameter) -> Result<Int32, ZstdError> {
    var r: Int32 = 0
    return nothingOrZstdError {
      ZSTD_DCtx_getParameter(context, param, &r)
    }
    .map { r }
  }
}
#endif
