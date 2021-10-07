import CZstd

public struct ZstdError: Error, CustomStringConvertible {

  public let code: Int

  public var description: String {
    String(cString: ZSTD_getErrorName(code))
  }
}

@usableFromInline
func valueOrZstdError(_ body: () -> Int) throws -> Int {
  let v = body()
  if ZSTD_isError(v) != 0 {
    throw ZstdError(code: v)
  }
  return v
}

@usableFromInline
func nothingOrZstdError(_ body: () -> Int) throws {
  _ = try valueOrZstdError(body)
}
