import CZstd

extension ZSTD_bounds {
  func getRange() throws -> ClosedRange<Int32> {
    try nothingOrZstdError(error)
    return lowerBound...upperBound
  }
}
