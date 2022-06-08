import CZstd
@_exported import protocol Foundation.ContiguousBytes
import CUtility

public enum Zstd { }

public extension Zstd {

  @inlinable
  @_alwaysEmitIntoClient
  static func compress(src: any ContiguousBytes, dst: UnsafeMutableRawBufferPointer, compressionLevel: Int32) -> Result<Int, ZstdError> {
    valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_compress(dst.baseAddress, dst.count, src.baseAddress, src.count, compressionLevel)
      }
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func decompress(src: any ContiguousBytes, dst: UnsafeMutableRawBufferPointer) -> Result<Int, ZstdError> {
     valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_decompress(dst.baseAddress, dst.count, src.baseAddress, src.count)
      }
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  static var versionNumber: UInt32 {
    ZSTD_versionNumber()
  }

  @_alwaysEmitIntoClient
  static var version: StaticCString {
    .init(cString: ZSTD_versionString())
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func getFrameContentSize(src: any ContiguousBytes) -> Result<UInt64, ZstdError> {
    valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_getFrameContentSize(src.baseAddress, src.count)
      }
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  static var contentSizeError: UInt64 {
    ZSTD_CONTENTSIZE_ERROR
  }

  @inlinable
  @_alwaysEmitIntoClient
  static var contentSizeUnknown: UInt64 {
    ZSTD_CONTENTSIZE_UNKNOWN
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func findFrameCompressedSize(src: any ContiguousBytes) -> Result<Int, ZstdError> {
    valueOrZstdError {
      src.withUnsafeBytes { src in
        ZSTD_findFrameCompressedSize(src.baseAddress, src.count)
      }
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  static var compressionLevelRange: ClosedRange<Int32> {
    ZSTD_minCLevel()...ZSTD_maxCLevel()
  }

  @inlinable
  @_alwaysEmitIntoClient
  static var defaultCompressionLevel: Int32 {
    ZSTD_defaultCLevel()
  }

  @inlinable
  @_alwaysEmitIntoClient
  static var compressionInputBufferSize: Int {
    ZSTD_CStreamInSize()
  }

  @inlinable
  @_alwaysEmitIntoClient
  static var compressionOutputBufferSize: Int {
    ZSTD_CStreamOutSize()
  }

  @inlinable
  @_alwaysEmitIntoClient
  static var decompressionInputBufferSize: Int {
    ZSTD_DStreamInSize()
  }

  @inlinable
  @_alwaysEmitIntoClient
  static var decompressionOutputBufferSize: Int {
    ZSTD_DStreamOutSize()
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func maximumCompressedSize(srcSize: Int) -> Int {
    ZSTD_compressBound(srcSize)
  }

  typealias Strategy = ZSTD_strategy

  typealias ResetDirective = ZSTD_ResetDirective

  typealias EndDirective = ZSTD_EndDirective

  typealias InBuffer = ZSTD_inBuffer

  typealias OutBuffer = ZSTD_outBuffer

  typealias CompressionParameter = ZSTD_cParameter

  typealias DecompressionParameter = ZSTD_dParameter

  @inlinable
  @_alwaysEmitIntoClient
  static var emptyInput: InBuffer {
    .init(src: nil, size: 0, pos: 0)
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func getDictionaryID(fromDictionary dict: any ContiguousBytes) -> UInt32 {
    dict.withUnsafeBytes { buffer in
      ZSTD_getDictID_fromDict(buffer.baseAddress, buffer.count)
    }
  }

  @inlinable
  @_alwaysEmitIntoClient
  static func getDictionaryID(fromFrame frame: any ContiguousBytes) -> UInt32 {
    frame.withUnsafeBytes { buffer in
      ZSTD_getDictID_fromFrame(buffer.baseAddress, buffer.count)
    }
  }

}

public extension Zstd.ResetDirective {
  @_alwaysEmitIntoClient
  static var session: Self { ZSTD_reset_session_only }
  @_alwaysEmitIntoClient
  static var parameters: Self { ZSTD_reset_parameters }
  @_alwaysEmitIntoClient
  static var sessionAndParameters: Self { ZSTD_reset_session_and_parameters }
}

public extension Zstd.EndDirective {
  @_alwaysEmitIntoClient
  static var `continue`: Self { ZSTD_e_continue }
  @_alwaysEmitIntoClient
  static var flush: Self { ZSTD_e_flush }
  @_alwaysEmitIntoClient
  static var end: Self { ZSTD_e_end }
}

public extension Zstd.InBuffer {
  @inlinable
  @_alwaysEmitIntoClient
  init(_ buffer: UnsafeRawBufferPointer) {
    self.init(src: buffer.baseAddress, size: buffer.count, pos: 0)
  }

  @inlinable
  @_alwaysEmitIntoClient
  init(_ buffer: UnsafeMutableRawBufferPointer) {
    self.init(src: buffer.baseAddress, size: buffer.count, pos: 0)
  }

  @inlinable
  @_alwaysEmitIntoClient
  var isCompleted: Bool {
    size == pos
  }
}


public extension Zstd.OutBuffer {
  @inlinable
  @_alwaysEmitIntoClient
  init(_ buffer: UnsafeMutableRawBufferPointer) {
    self.init(dst: buffer.baseAddress, size: buffer.count, pos: 0)
  }
}

public extension Zstd.CompressionParameter {
  @_alwaysEmitIntoClient
  static var compressionLevel: Self { ZSTD_c_compressionLevel }
  @_alwaysEmitIntoClient
  static var windowLog: Self { ZSTD_c_windowLog }
  @_alwaysEmitIntoClient
  static var hashLog: Self { ZSTD_c_hashLog }
  @_alwaysEmitIntoClient
  static var chainLog: Self { ZSTD_c_chainLog }
  @_alwaysEmitIntoClient
  static var searchLog: Self { ZSTD_c_searchLog }
  @_alwaysEmitIntoClient
  static var minMatch: Self { ZSTD_c_minMatch }
  @_alwaysEmitIntoClient
  static var targetLength: Self { ZSTD_c_targetLength }
  @_alwaysEmitIntoClient
  static var strategy: Self { ZSTD_c_strategy }
  @_alwaysEmitIntoClient
  static var enableLongDistanceMatching: Self { ZSTD_c_enableLongDistanceMatching }
  @_alwaysEmitIntoClient
  static var ldmHashLog: Self { ZSTD_c_ldmHashLog }
  @_alwaysEmitIntoClient
  static var ldmMinMatch: Self { ZSTD_c_ldmMinMatch }
  @_alwaysEmitIntoClient
  static var ldmBucketSizeLog: Self { ZSTD_c_ldmBucketSizeLog }
  @_alwaysEmitIntoClient
  static var ldmHashRateLog: Self { ZSTD_c_ldmHashRateLog }
  @_alwaysEmitIntoClient
  static var contentSizeFlag: Self { ZSTD_c_contentSizeFlag }
  @_alwaysEmitIntoClient
  static var checksumFlag: Self { ZSTD_c_checksumFlag }
  @_alwaysEmitIntoClient
  static var dictIDFlag: Self { ZSTD_c_dictIDFlag }
  @_alwaysEmitIntoClient
  static var nbWorkers: Self { ZSTD_c_nbWorkers }
  @_alwaysEmitIntoClient
  static var jobSize: Self { ZSTD_c_jobSize }
  @_alwaysEmitIntoClient
  static var overlapLog: Self { ZSTD_c_overlapLog }
}

public extension Zstd.DecompressionParameter {
  @_alwaysEmitIntoClient
  static var windowLogMax: Self { ZSTD_d_windowLogMax }
}

public extension Zstd.Strategy {
  @_alwaysEmitIntoClient
  static var fast: Self { ZSTD_fast }
  @_alwaysEmitIntoClient
  static var dfast: Self { ZSTD_dfast }
  @_alwaysEmitIntoClient
  static var greedy: Self { ZSTD_greedy }
  @_alwaysEmitIntoClient
  static var lazy: Self { ZSTD_lazy }
  @_alwaysEmitIntoClient
  static var lazy2: Self { ZSTD_lazy2 }
  @_alwaysEmitIntoClient
  static var btlazy2: Self { ZSTD_btlazy2 }
  @_alwaysEmitIntoClient
  static var btopt: Self { ZSTD_btopt }
  @_alwaysEmitIntoClient
  static var btultra: Self { ZSTD_btultra }
  @_alwaysEmitIntoClient
  static var btultra2: Self { ZSTD_btultra2 }
}

public extension Zstd.CompressionParameter {
  @inlinable
  @_alwaysEmitIntoClient
  var bounds: Result<ClosedRange<Int32>, ZstdError> {
    ZSTD_cParam_getBounds(self).toResult()
  }
}

public extension Zstd.DecompressionParameter {
  @inlinable
  @_alwaysEmitIntoClient
  var bounds: Result<ClosedRange<Int32>, ZstdError> {
    ZSTD_dParam_getBounds(self).toResult()
  }
}
