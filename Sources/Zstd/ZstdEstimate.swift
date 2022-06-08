#if ZSTD_EXPERIMENTAL
import CZstd

public extension Zstd {

  @inlinable
  @_alwaysEmitIntoClient
  static func compressionContextSize(compressionLevel: Int32) -> Int {
    ZSTD_estimateCCtxSize(compressionLevel)
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func compressionContextSize(compressionP: ZSTD_compressionParameters) -> Int {
    ZSTD_estimateCCtxSize_usingCParams(compressionP)
  }

  @inlinable
  @_alwaysEmitIntoClient
  static var decompressionContextSize: Int {
    ZSTD_estimateDCtxSize()
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func compressionStreamSize(compressionLevel: Int32) -> Int {
    ZSTD_estimateCStreamSize(compressionLevel)
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func compressionStreamSize(compressionP: ZSTD_compressionParameters) -> Int {
    ZSTD_estimateCStreamSize_usingCParams(compressionP)
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func decompressionStreamSize(windowSize: Int) -> Int {
    ZSTD_estimateDStreamSize(windowSize)
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func decompressionStreamSize(frame: any ContiguousBytes) -> Int {
    frame.withUnsafeBytes { buffer in
      ZSTD_estimateDStreamSize_fromFrame(buffer.baseAddress, buffer.count)
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func compressionDictionarySize(dictsize: Int, compressionLevel: Int32) -> Int {
    ZSTD_estimateCDictSize(dictsize, compressionLevel)
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func compressionDictionarySize(dictsize: Int, compressionP: ZSTD_compressionParameters, dictLoadMethod: ZSTD_dictLoadMethod_e) -> Int {
    ZSTD_estimateCDictSize_advanced(dictsize, compressionP, dictLoadMethod)
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func decompressionDictionarySize(dictsize: Int, dictLoadMethod: ZSTD_dictLoadMethod_e) -> Int {
    ZSTD_estimateDDictSize(dictsize, dictLoadMethod)
  }

}
#endif
