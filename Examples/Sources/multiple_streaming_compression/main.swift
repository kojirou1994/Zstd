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

let context = try ZstdCompressionContext()
try context.set(7, for: .compressionLevel)
try context.set(true,  for: .checksumFlag)

let fileBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: Zstd.recommendedInputBufferSize, alignment: MemoryLayout<UInt8>.alignment)
defer { fileBuffer.deallocate() }
let compressBuffer = UnsafeMutableRawBufferPointer.allocate(byteCount: Zstd.recommendedOutputBufferSize, alignment: MemoryLayout<UInt8>.alignment)
defer { compressBuffer.deallocate() }

var inputZ = Zstd.InBuffer(fileBuffer)
var outputZ = Zstd.OutBuffer(compressBuffer)

for inFile in inFiles {
  let inFileURL = URL(fileURLWithPath: inFile)
  let outFileURL = inFileURL.appendingPathExtension("zst")

  let inFd = try FileDescriptor.open(FilePath(inFile), .readOnly)
  defer { try? inFd.close() }

  let outFd = try FileDescriptor.open(FilePath(outFileURL)!, .writeOnly, options: [.create, .truncate], permissions: [.ownerReadWrite])
  defer { try? outFd.close() }

  let toRead = fileBuffer.count
  while true {
    let read = try inFd.read(into: fileBuffer)
    let lastChunk = read < toRead
    let mode: Zstd.EndDirective = lastChunk ? .end : .continue
    inputZ.size = read
    inputZ.pos = 0
    var finished = false
    repeat {
      outputZ.pos = 0
      let remaining = try context.compressStream2(inBuffer: &inputZ, outBuffer: &outputZ, endOp: mode)
      _ = try outFd.write(UnsafeRawBufferPointer(rebasing: compressBuffer.prefix(outputZ.pos)))
      finished = lastChunk ? (remaining == 0) : inputZ.isCompleted
    } while !finished
    if lastChunk {
      break
    }
  }

  print("\(inFile) : \(inFileSize) -> \(newSize) - \(outFileURL.path) ")
}
