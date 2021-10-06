import CZstd

public final class ZstdCompressionDictionary {
  let dic: OpaquePointer

  public init<T: ContiguousBytes>(buffer: T, compressionLevel: Int32) throws {
    dic = try buffer.withUnsafeBytes { buffer in
      try ZSTD_createCDict(buffer.baseAddress, buffer.count, compressionLevel).zstdUnwrap()
    }
  }

  public init(compressionLevel: Int32) throws {
    dic = try ZSTD_createCDict(nil, 0, compressionLevel).zstdUnwrap()
  }

  deinit {
    ZSTD_freeCDict(dic)
  }

  public var size: Int {
    ZSTD_sizeof_CDict(dic)
  }
}

public final class ZstdDecompressionDictionary {
  let dic: OpaquePointer

  public init<T: ContiguousBytes>(buffer: T) throws {
    dic = try buffer.withUnsafeBytes { buffer in
      try ZSTD_createDDict(buffer.baseAddress, buffer.count).zstdUnwrap()
    }
  }

  deinit {
    ZSTD_freeDDict(dic)
  }

  public var id: UInt32 {
    ZSTD_getDictID_fromDDict(dic)
  }

  public var size: Int {
    ZSTD_sizeof_DDict(dic)
  }
}
