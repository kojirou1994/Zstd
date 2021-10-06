import CZstd

public extension ZstdDecompressionContext {
  func value(for param: Zstd.DecompressionParameter) throws -> Int32 {
    var r: Int32 = 0
    try nothingOrZstdError {
      ZSTD_DCtx_getParameter(context, param, &r)
    }
    return r
  }
}
