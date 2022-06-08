extension Optional where Wrapped == OpaquePointer {
  @usableFromInline
  func zstdUnwrap() throws -> Wrapped {
    guard let v = self else {
      throw ZstdError(rawValue: -64) /* ZSTD_error_memory_allocation */
    }
    return v
  }
}
