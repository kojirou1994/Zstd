import CZstd

public enum ZstdEstimate { }

public extension ZstdEstimate {

  static func compressionContextSize(compressionLevel: Int32) -> Int {
    ZSTD_estimateCCtxSize(compressionLevel)
  }

  static func compressionContextSize(compressionP: ZSTD_compressionParameters) -> Int {
    ZSTD_estimateCCtxSize_usingCParams(compressionP)
  }

  static var decompressionContextSize: Int {
    ZSTD_estimateDCtxSize()
  }

  static func compressionStreamSize(compressionLevel: Int32) -> Int {
    ZSTD_estimateCStreamSize(compressionLevel)
  }

  static func compressionStreamSize(compressionP: ZSTD_compressionParameters) -> Int {
    ZSTD_estimateCStreamSize_usingCParams(compressionP)
  }

  static func decompressionStreamSize(windowSize: Int) -> Int {
    ZSTD_estimateDStreamSize(windowSize)
  }

  static func decompressionStreamSize(frame: UnsafeRawBufferPointer) -> Int {
    ZSTD_estimateDStreamSize_fromFrame(frame.baseAddress, frame.count)
  }

  static func compressionDictionarySize(dictsize: Int, compressionLevel: Int32) -> Int {
    ZSTD_estimateCDictSize(dictsize, compressionLevel)
  }

  static func compressionDictionarySize(dictsize: Int, compressionP: ZSTD_compressionParameters, dictLoadMethod: ZSTD_dictLoadMethod_e) -> Int {
    ZSTD_estimateCDictSize_advanced(dictsize, compressionP, dictLoadMethod)
  }

  static func decompressionDictionarySize(dictsize: Int, dictLoadMethod: ZSTD_dictLoadMethod_e) -> Int {
    ZSTD_estimateDDictSize(dictsize, dictLoadMethod)
  }

}