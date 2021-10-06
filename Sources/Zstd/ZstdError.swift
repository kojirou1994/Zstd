import CZstd

public struct ZstdError: Error, CustomStringConvertible {

  public let code: Int

  public var description: String {
    String(cString: ZSTD_getErrorName(code))
  }
}

func valueOrZstdError(_ body: () -> Int) throws -> Result<Int, ZstdError> {
  let v = body()
  if ZSTD_isError(v) != 0 {
    return .failure(ZstdError(code: v))
  }
  return .success(v)
}

func nothingOrZstdError(_ body: () -> Int) throws {
  _ = try valueOrZstdError(body).get()
}
