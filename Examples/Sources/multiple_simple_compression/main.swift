import Foundation
import Zstd
import System

if CommandLine.argc < 2 {
  print("wrong arguments")
  print("usage:")
  print("\(CommandLine.arguments[0]) FILE(s)")
  exit(1)
}

let inFiles = CommandLine.arguments.dropFirst()
let maxFileSize = try inFiles.lazy.map { try FileManager.default.attributesOfItem(atPath: $0)[.size] as! Int }.max()!

let fileBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: maxFileSize, alignment: MemoryLayout<UInt8>.alignment)
defer { fileBuffer.deallocate() }
let compressBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: Zstd.maximumCompressedSize(srcSize: maxFileSize), alignment: MemoryLayout<UInt8>.alignment)
defer { compressBuffer.deallocate() }

let context = try ZstdCompressionContext()

for inFile in inFiles {
  let inFileURL = URL(fileURLWithPath: inFile)
  let outFileURL = inFileURL.appendingPathExtension("zst")
  let inFileSize = try FileManager.default.attributesOfItem(atPath: inFile)[.size] as! Int

  let inFd = try FileDescriptor.open(FilePath(inFile), .readOnly)
  defer { try? inFd.close() }

  let outFd = try FileDescriptor.open(FilePath(outFileURL)!, .writeOnly, options: [.create, .truncate], permissions: [.ownerReadWrite])
  defer { try? outFd.close() }

  let thisFileBuffer = UnsafeMutableRawBufferPointer(rebasing: fileBuffer.prefix(inFileSize))
  _ = try inFd.read(into: thisFileBuffer)

  let newSize = try context.compress(src: thisFileBuffer, dst: compressBuffer, compressionLevel: 1).get()

  _ = try outFd.write(UnsafeRawBufferPointer(rebasing: compressBuffer.prefix(newSize)))

  print("\(inFile) : \(inFileSize) -> \(newSize) - \(outFileURL.path) ")
}

