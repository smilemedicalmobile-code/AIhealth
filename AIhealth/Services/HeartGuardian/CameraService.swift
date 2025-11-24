import AVFoundation
import UIKit

class CameraService: NSObject, ObservableObject {
    @Published var error: String?
    @Published var isSessionRunning = false

    private let captureSession = AVCaptureSession()
    private var videoOutput: AVCaptureVideoDataOutput?
    private var device: AVCaptureDevice?

    var frameHandler: ((CMSampleBuffer) -> Void)?

    override init() {
        super.init()
    }

    func checkPermissions() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }

    func startSession() async {
        guard await checkPermissions() else {
            await MainActor.run {
                self.error = "hg_error_camera_permission".localized
            }
            return
        }

        captureSession.beginConfiguration()

        // 후면 카메라 설정
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            await MainActor.run {
                self.error = "hg_error_no_camera".localized
            }
            return
        }

        device = camera

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            // 비디오 출력 설정
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            output.alwaysDiscardsLateVideoFrames = true

            let queue = DispatchQueue(label: "com.aihealth.camera")
            output.setSampleBufferDelegate(self, queue: queue)

            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
                videoOutput = output
            }

            captureSession.commitConfiguration()

            // 세션 시작
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
                DispatchQueue.main.async {
                    self?.isSessionRunning = true
                }
            }

            // 플래시 켜기
            try enableTorch()

        } catch {
            await MainActor.run {
                self.error = "\("hg_error_camera_setup".localized): \(error.localizedDescription)"
            }
        }
    }

    func stopSession() {
        disableTorch()
        captureSession.stopRunning()
        isSessionRunning = false
    }

    private func enableTorch() throws {
        guard let device = device, device.hasTorch else {
            return
        }

        try device.lockForConfiguration()
        device.torchMode = .on
        device.unlockForConfiguration()
    }

    private func disableTorch() {
        guard let device = device, device.hasTorch else {
            return
        }

        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
        } catch {
            print("Failed to disable torch: \(error)")
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameHandler?(sampleBuffer)
    }
}
