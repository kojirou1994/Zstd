import CZstd

public final class ZstdCompressionContext {

  @usableFromInline
  internal let context: OpaquePointer

  @inlinable
  @_alwaysEmitIntoClient
  public init() throws {
    context = try ZSTD_createCCtx().zstdUnwrap()
  }

  @inlinable
  @_alwaysEmitIntoClient
  deinit {
    ZSTD_freeCCtx(context)
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func compress(src: any ContiguousBytes, dst: UnsafeMutableRawBufferPointer, compressionLevel: Int32) -> Result<Int, ZstdError> {
    valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_compressCCtx(context, dst.baseAddress, dst.count, src.baseAddress, src.count, compressionLevel)
      }
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func compress2(src: any ContiguousBytes, dst: UnsafeMutableRawBufferPointer) -> Result<Int, ZstdError> {
    valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_compress2(context, dst.baseAddress, dst.count, src.baseAddress, src.count)
      }
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func compress(src: any ContiguousBytes, dst: UnsafeMutableRawBufferPointer, dictionary: any ContiguousBytes, compressionLevel: Int32) -> Result<Int, ZstdError> {
    valueOrZstdError {
      src.withUnsafeBytes { src in
        dictionary.withUnsafeBytes { dictionary in
          ZSTD_compress_usingDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dictionary.baseAddress, dictionary.count, compressionLevel)
        }
      }
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func compress(src: any ContiguousBytes, dst: UnsafeMutableRawBufferPointer, dict: ZstdCompressionDictionary) -> Result<Int, ZstdError> {
    valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_compress_usingCDict(context, dst.baseAddress, dst.count, src.baseAddress, src.count, dict.op)
      }
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func compressStream(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer) -> Result<Int, ZstdError> {
    valueOrZstdError {
      ZSTD_compressStream(context, &outBuffer, &inBuffer)
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func flushStream(outBuffer: inout Zstd.OutBuffer) -> Result<Int, ZstdError> {
    valueOrZstdError {
      ZSTD_flushStream(context, &outBuffer)
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func endStream(outBuffer: inout Zstd.OutBuffer) -> Result<Int, ZstdError> {
    valueOrZstdError{
      ZSTD_endStream(context, &outBuffer)
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func compressStream2(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer, endOp: Zstd.EndDirective) -> Result<Int, ZstdError> {
    valueOrZstdError {
      ZSTD_compressStream2(context, &outBuffer, &inBuffer, endOp)
    }
  }

  public func set<T: FixedWidthInteger>(_ value: T, for param: Zstd.CompressionParameter) -> Result<Void, ZstdError> {
    nothingOrZstdError {
      ZSTD_CCtx_setParameter(context, param, Int32(value))
    }
  }

  public func set<T: RawRepresentable>(_ value: T,  for param: Zstd.CompressionParameter) -> Result<Void, ZstdError> where T.RawValue: FixedWidthInteger {
    set(value.rawValue, for: param)
  }

  public func set(_ value: Bool, for param: Zstd.CompressionParameter) -> Result<Void, ZstdError> {
    set(value ? 1 as Int32 : 0, for: param)
  }

  public func set(pledgedSrcSize: UInt64) -> Result<Void, ZstdError> {
    nothingOrZstdError {
      ZSTD_CCtx_setPledgedSrcSize(context, pledgedSrcSize)
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func reset(directive: Zstd.ResetDirective) -> Result<Void, ZstdError> {
    nothingOrZstdError {
      ZSTD_CCtx_reset(context, directive)
    }
  }

  @usableFromInline
  internal var referencedDictionary: ZstdCompressionDictionary?

  @inlinable
  @_alwaysEmitIntoClient
  public func load(dictionary: any ContiguousBytes) -> Result<Void, ZstdError> {
    nothingOrZstdError {
      dictionary.withUnsafeBytes { buffer in
        ZSTD_CCtx_loadDictionary(context, buffer.baseAddress, buffer.count)
      }
    }
    .map {
      referencedDictionary = nil
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func ref(dictionary: ZstdCompressionDictionary) -> Result<Void, ZstdError> {
    nothingOrZstdError {
      ZSTD_CCtx_refCDict(context, dictionary.op)
    }
    .map {
      referencedDictionary = dictionary
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func ref(prefix: UnsafeRawBufferPointer) -> Result<Void, ZstdError> {
    nothingOrZstdError {
      ZSTD_CCtx_refPrefix(context, prefix.baseAddress, prefix.count)
    }
    .map {
      referencedDictionary = nil
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public func unloadDictionary() -> Result<Void, ZstdError> {
    nothingOrZstdError {
      ZSTD_CCtx_refCDict(context, nil)
    }
    .map {
      referencedDictionary = nil
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public var size: Int {
    ZSTD_sizeof_CCtx(context)
  }
}

// MARK: Helper
public extension ZstdCompressionContext {
  func compressStreamAll(inBuffer: inout Zstd.InBuffer, outBuffer: inout Zstd.OutBuffer, endOp: Zstd.EndDirective, body: (UnsafeRawBufferPointer) throws -> Void) throws {
    repeat {
      outBuffer.pos = 0
      let remaining = try compressStream2(inBuffer: &inBuffer, outBuffer: &outBuffer, endOp: endOp).get()
      try body(.init(start: outBuffer.dst, count: outBuffer.pos))
      if endOp == .end ? remaining == 0 : inBuffer.isCompleted {
        return
      }
    } while true
  }
}

// MARK: Experimental APIs
#if ZSTD_EXPERIMENTAL
public extension ZstdCompressionContext {
  @inlinable
  @_alwaysEmitIntoClient
  func value(for param: Zstd.CompressionParameter) -> Result<Int32, ZstdError> {
    var r: Int32 = 0
    return nothingOrZstdError {
      ZSTD_CCtx_getParameter(context, param, &r)
    }
    .map { r }
  }
}

extension ZstdCompressionContext {
  public final class Parameters {

    @usableFromInline
    internal let params: OpaquePointer

    @inlinable
    @_alwaysEmitIntoClient
    public init() throws {
      params = try ZSTD_createCCtxParams().zstdUnwrap()
    }

    @inlinable
    @_alwaysEmitIntoClient
    deinit {
      ZSTD_freeCCtxParams(params)
    }

    @inlinable
    @_alwaysEmitIntoClient
    public func set<T: FixedWidthInteger>(_ value: T, for param: Zstd.CompressionParameter) -> Result<Void, ZstdError> {
      nothingOrZstdError {
        ZSTD_CCtxParams_setParameter(params, param, Int32(value))
      }
    }

    @inlinable
    @_alwaysEmitIntoClient
    public func set<T: RawRepresentable>(_ value: T,  for param: Zstd.CompressionParameter) -> Result<Void, ZstdError> where T.RawValue: FixedWidthInteger {
      set(value.rawValue, for: param)
    }

    @inlinable
    @_alwaysEmitIntoClient
    public func set(_ value: Bool, for param: Zstd.CompressionParameter) -> Result<Void, ZstdError> {
      set(value ? 1 as Int32 : 0, for: param)
    }

    @inlinable
    @_alwaysEmitIntoClient
    public func value(for param: Zstd.CompressionParameter) -> Result<Int32, ZstdError> {
      var r: Int32 = 0
      return nothingOrZstdError {
        ZSTD_CCtxParams_getParameter(params, param, &r)
      }
      .map { r }
    }

    @inlinable
    @_alwaysEmitIntoClient
    public func reset() {
      ZSTD_CCtxParams_reset(params)
    }

    @inlinable
    @_alwaysEmitIntoClient
    public func estimateCompressionContextSize() -> Result<Int, ZstdError> {
      assert(try! value(for: .nbWorkers).get() == 0)
      return valueOrZstdError {
        ZSTD_estimateCCtxSize_usingCCtxParams(params)
      }
    }

    @inlinable
    @_alwaysEmitIntoClient
    public func estimateCompressionStreamSize() -> Result<Int, ZstdError> {
      assert(try! value(for: .nbWorkers).get() == 0)
      return valueOrZstdError {
        ZSTD_estimateCStreamSize_usingCCtxParams(params)
      }
    }

  }
}

extension ZstdCompressionContext {
  @inlinable
  @_alwaysEmitIntoClient
  public func set(parameters: Parameters) {
    ZSTD_CCtx_setParametersUsingCCtxParams(context, parameters.params)
  }
}

#endif
