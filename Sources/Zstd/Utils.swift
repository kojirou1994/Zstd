extension Optional where Wrapped == OpaquePointer {
  func zstdUnwrap() throws -> Wrapped {
    guard let v = self else {
      throw ZstdError(code: 64) /* ZSTD_error_memory_allocation */
    }
    return v
  }
}
