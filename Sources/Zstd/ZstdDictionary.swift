import CZstd

public final class ZstdCompressionDictionary {
  let dic: OpaquePointer

  public init<T: ContiguousBytes>(buffer: T, compressionLevel: Int32) throws {
    dic = buffer.withUnsafeBytes { buffer in
      ZSTD_createCDict(buffer.baseAddress, buffer.count, compressionLevel)!
    }
  }

  public init(compressionLevel: Int32) throws {
    dic = ZSTD_createCDict(nil, 0, compressionLevel)!
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
    dic = buffer.withUnsafeBytes { buffer in
      ZSTD_createDDict(buffer.baseAddress, buffer.count)!
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
