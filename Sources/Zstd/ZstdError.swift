import CZstd

public struct ZstdError: Error, CustomStringConvertible {
  let code: Int

  public var description: String {
    String(cString: ZSTD_getErrorName(code))
  }
}

func valueOrZstdError(_ v: Int) throws -> Result<Int, ZstdError> {
  if ZSTD_isError(v) != 0 {
    return .failure(ZstdError(code: v))
  }
  return .success(v)
}

func nothingOrZstdError(_ v: Int) throws {
  _ = try valueOrZstdError(v).get()
}
