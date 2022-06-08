import CZstd
import CUtility

public struct ZstdError: RawRepresentable, Error, CustomStringConvertible {
  
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public let rawValue: Int

  @inlinable
  @_alwaysEmitIntoClient
  public var name: StaticCString {
    .init(cString: ZSTD_getErrorName(rawValue))
  }

  public var description: String {
    "\(String(describing: Self.self))(code: \(rawValue), name: \(name.string))"
  }
}

@inlinable
func valueOrZstdError<T: FixedWidthInteger>(_ body: () -> T) -> Result<T, ZstdError> {
  let v = body()
  if _slowPath(ZSTD_isError(Int(v)) != 0) {
    return .failure(ZstdError(rawValue: Int(v)))
  }
  return .success(v)
}

@inlinable
func nothingOrZstdError(_ body: () -> Int) -> Result<Void, ZstdError> {
  valueOrZstdError(body).map { _ in () }
}
