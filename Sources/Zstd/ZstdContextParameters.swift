import CZstd

extension ZstdCompressionContext {
  public final class Parameters {

    fileprivate let params: OpaquePointer

    public init() throws {
      params = try ZSTD_createCCtxParams().zstdUnwrap()
    }

    deinit {
      ZSTD_freeCCtxParams(params)
    }

    public func set<T: FixedWidthInteger>(_ value: T, for param: Zstd.CompressionParameter) throws {
      try nothingOrZstdError {
        ZSTD_CCtxParams_setParameter(params, param, Int32(value))
      }
    }

    public func set<T: RawRepresentable>(_ value: T,  for param: Zstd.CompressionParameter) throws where T.RawValue: FixedWidthInteger {
      try set(value.rawValue, for: param)
    }

    public func set(_ value: Bool, for param: Zstd.CompressionParameter) throws {
      try set(value ? 1 as Int32 : 0, for: param)
    }

    public func value(for param: Zstd.CompressionParameter) throws -> Int32 {
      var r: Int32 = 0
      try nothingOrZstdError {
        ZSTD_CCtxParams_getParameter(params, param, &r)
      }
      return r
    }

    public func reset() throws {
      ZSTD_CCtxParams_reset(params)
    }

  }
}

extension ZstdCompressionContext {
  public func set(parameters: Parameters) throws {
    ZSTD_CCtx_setParametersUsingCCtxParams(context, parameters.params)
  }
}
