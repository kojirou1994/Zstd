//@_implementationOnly
import CZstd

public func test() {
  ZSTD_compressBound(1)

}

public enum Zstd { }

public extension Zstd {

  static func compress(src: UnsafeRawBufferPointer, dst: UnsafeMutableRawBufferPointer, compressionLevel: Int32) throws -> Int {
    try valueOrZstdError(ZSTD_compress(dst.baseAddress, dst.count, src.baseAddress, src.count, compressionLevel)).get()
  }

  static func decompress(src: UnsafeRawBufferPointer, dst: UnsafeMutableRawBufferPointer, compressionLevel: Int32) throws -> Int {
    try valueOrZstdError(ZSTD_decompress(dst.baseAddress, dst.count, src.baseAddress, src.count)).get()
  }

  static var versionNumber: UInt32 {
    ZSTD_versionNumber()
  }

  static let version: String = String(cString: ZSTD_versionString())

  static func getFrameContentSize(src: UnsafeRawBufferPointer) throws -> UInt64 {
    ZSTD_getFrameContentSize(src.baseAddress, src.count)
  }

  static func findFrameCompressedSize(src: UnsafeRawBufferPointer) throws -> Int {
    ZSTD_findFrameCompressedSize(src.baseAddress, src.count)
  }

  static var compressionLevelRange: ClosedRange<Int32> {
    ZSTD_minCLevel()...ZSTD_maxCLevel()
  }

  static var defaultCompressionLevel: Int32 {
    ZSTD_defaultCLevel()
  }

  static var recommendedInputBufferSize: Int {
    ZSTD_CStreamInSize()
  }

  static var recommendedOutputBufferSize: Int {
    ZSTD_CStreamOutSize()
  }

  static func maximumCompressedSize(srcSize: Int) -> Int {
    ZSTD_compressBound(srcSize)
  }

  typealias ResetDirective = ZSTD_ResetDirective

  typealias EndDirective = ZSTD_EndDirective

  typealias InBuffer = ZSTD_inBuffer

  typealias OutBuffer = ZSTD_outBuffer

  typealias CompressionParameter = ZSTD_cParameter

  typealias DecompressionParameter = ZSTD_dParameter

  static func getBounds(param: CompressionParameter) throws -> ClosedRange<Int32> {
    try ZSTD_cParam_getBounds(param).getRange()
  }

  static func getBounds(param: DecompressionParameter) throws -> ClosedRange<Int32> {
    try ZSTD_dParam_getBounds(param).getRange()
  }

}

public extension Zstd.ResetDirective {
  static var session: Self { ZSTD_reset_session_only }

  static var parameters: Self { ZSTD_reset_parameters }

  static var sessionAndParameters: Self { ZSTD_reset_session_and_parameters }
}

public extension Zstd.EndDirective {
  static var `continue`: Self { ZSTD_e_continue }

  static var flush: Self { ZSTD_e_flush }

  static var end: Self { ZSTD_e_end }
}

public extension Zstd.InBuffer {
  init(buffer: UnsafeRawBufferPointer) {
    self.init(src: buffer.baseAddress, size: buffer.count, pos: 0)
  }

  init(buffer: UnsafeMutableRawBufferPointer) {
    self.init(src: buffer.baseAddress, size: buffer.count, pos: 0)
  }

  var isCompleted: Bool {
    size == pos
  }
}


public extension Zstd.OutBuffer {
  init(buffer: UnsafeMutableRawBufferPointer) {
    self.init(dst: buffer.baseAddress, size: buffer.count, pos: 0)
  }
}

public extension Zstd.CompressionParameter {
  static var compressionLevel: Self { ZSTD_c_compressionLevel }
  static var windowLog: Self { ZSTD_c_windowLog }
  static var hashLog: Self { ZSTD_c_hashLog }
  static var chainLog: Self { ZSTD_c_chainLog }
  static var searchLog: Self { ZSTD_c_searchLog }
  static var minMatch: Self { ZSTD_c_minMatch }
  static var targetLength: Self { ZSTD_c_targetLength }
  static var strategy: Self { ZSTD_c_strategy }
  static var enableLongDistanceMatching: Self { ZSTD_c_enableLongDistanceMatching }
  static var ldmHashLog: Self { ZSTD_c_ldmHashLog }
  static var ldmMinMatch: Self { ZSTD_c_ldmMinMatch }
  static var ldmBucketSizeLog: Self { ZSTD_c_ldmBucketSizeLog }
  static var ldmHashRateLog: Self { ZSTD_c_ldmHashRateLog }
  static var contentSizeFlag: Self { ZSTD_c_contentSizeFlag }
  static var checksumFlag: Self { ZSTD_c_checksumFlag }
  static var dictIDFlag: Self { ZSTD_c_dictIDFlag }
  static var nbWorkers: Self { ZSTD_c_nbWorkers }
  static var jobSize: Self { ZSTD_c_jobSize }
  static var overlapLog: Self { ZSTD_c_overlapLog }
}

public extension Zstd.DecompressionParameter {
  static var windowLogMax: Self { ZSTD_d_windowLogMax }
}
