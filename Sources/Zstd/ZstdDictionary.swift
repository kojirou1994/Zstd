import CZstd

public final class ZstdCompressionDictionary {
  @usableFromInline
  internal let op: OpaquePointer

  @inlinable
  @_alwaysEmitIntoClient
  public init<T: ContiguousBytes>(buffer: T, compressionLevel: Int32) throws {
    op = try buffer.withUnsafeBytes { buffer in
      try ZSTD_createCDict(buffer.baseAddress, buffer.count, compressionLevel).zstdUnwrap()
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  public init(compressionLevel: Int32) throws {
    op = try ZSTD_createCDict(nil, 0, compressionLevel).zstdUnwrap()
  }

  @inlinable
  @_alwaysEmitIntoClient
  deinit {
    ZSTD_freeCDict(op)
  }

  @inlinable
  @_alwaysEmitIntoClient
  public var size: Int {
    ZSTD_sizeof_CDict(op)
  }
}

public final class ZstdDecompressionDictionary {
  @usableFromInline
  internal let op: OpaquePointer

  @inlinable
  @_alwaysEmitIntoClient
  public init(buffer: any ContiguousBytes) throws {
    op = try buffer.withUnsafeBytes { buffer in
      try ZSTD_createDDict(buffer.baseAddress, buffer.count).zstdUnwrap()
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  deinit {
    ZSTD_freeDDict(op)
  }

  @inlinable
  @_alwaysEmitIntoClient
  public var id: UInt32 {
    ZSTD_getDictID_fromDDict(op)
  }

  @inlinable
  @_alwaysEmitIntoClient
  public var size: Int {
    ZSTD_sizeof_DDict(op)
  }
}
