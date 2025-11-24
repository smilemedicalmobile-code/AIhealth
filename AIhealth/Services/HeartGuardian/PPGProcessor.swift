import AVFoundation
import CoreImage
import UIKit

class PPGProcessor {
    func processFrame(_ sampleBuffer: CMSampleBuffer) -> Double? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly) }

        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)

        guard let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer) else {
            return nil
        }

        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)

        var redSum: Int64 = 0
        var pixelCount: Int64 = 0

        // BGRA 포맷이므로 R은 index 2
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * bytesPerRow + x * 4
                let red = buffer[pixelIndex + 2]
                redSum += Int64(red)
                pixelCount += 1
            }
        }

        guard pixelCount > 0 else {
            return nil
        }

        return Double(redSum) / Double(pixelCount)
    }
}
