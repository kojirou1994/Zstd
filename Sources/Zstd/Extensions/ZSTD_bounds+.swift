import CZstd

extension ZSTD_bounds {
  @inlinable @inline(__always)
  @_alwaysEmitIntoClient
  func toResult() -> Result<ClosedRange<Int32>, ZstdError> {
    nothingOrZstdError { error }
      .map { lowerBound...upperBound }
  }
}
