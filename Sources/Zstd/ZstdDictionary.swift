import CZstd

public final class ZstdCompressionDictionary {
  let dic: OpaquePointer

  public init(buffer: UnsafeRawBufferPointer, compressionLevel: Int32) throws {
    dic = ZSTD_createCDict(buffer.baseAddress, buffer.count, compressionLevel)!
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

  init(buffer: UnsafeRawBufferPointer) throws {
    dic = ZSTD_createDDict(buffer.baseAddress, buffer.count)!
  }

  deinit {
    ZSTD_freeDDict(dic)
  }

  public var id: CUnsignedInt {
    ZSTD_getDictID_fromDDict(dic)
  }

  public var size: Int {
    ZSTD_sizeof_DDict(dic)
  }
}
