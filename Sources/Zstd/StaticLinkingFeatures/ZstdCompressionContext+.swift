import CZstd

public extension ZstdCompressionContext {
  func value(for param: Zstd.CompressionParameter) throws -> Int32 {
    var r: Int32 = 0
    try nothingOrZstdError {
      ZSTD_CCtx_getParameter(context, param, &r)
    }
    return r
  }
}
