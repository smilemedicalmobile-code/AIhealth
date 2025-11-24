import Foundation
import AVFoundation
import Combine

@MainActor
class HeartGuardianViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var ppgData: [PPGPoint] = []
    @Published var currentBpm: Double = 0
    @Published var progress: Double = 0
    @Published var status: String = "hg_status_initializing".localized
    @Published var error: String?
    @Published var isAnalyzing: Bool = false
    @Published var analysisResult: AnalysisResult?

    // MARK: - Services
    private let cameraService = CameraService()
    private let ppgProcessor = PPGProcessor()
    private let heartRateAnalyzer = HeartRateAnalyzer()
    private let interpretationService = HealthInterpretationService()

    // MARK: - Constants
    private let measurementDuration: TimeInterval = 30.0
    private let stabilizationTime: TimeInterval = 3.0
    private var measurementStartTime: Date?
    private var timer: Timer?

    // MARK: - Initialization
    init() {
        setupCameraHandler()
    }

    // MARK: - Camera Setup
    private func setupCameraHandler() {
        cameraService.frameHandler = { [weak self] sampleBuffer in
            guard let self = self else { return }

            if let redValue = self.ppgProcessor.processFrame(sampleBuffer) {
                Task { @MainActor in
                    self.handleNewPPGValue(redValue)
                }
            }
        }
    }

    // MARK: - Measurement Control
    func startMeasurement() async {
        await cameraService.startSession()

        if cameraService.error != nil {
            self.error = cameraService.error
            self.status = "hg_status_error".localized
            return
        }

        measurementStartTime = Date()
        status = "hg_status_stabilizing".localized

        startTimer()
    }

    func stopMeasurement() {
        timer?.invalidate()
        timer = nil
        cameraService.stopSession()
    }

    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.updateProgress()
            }
        }
    }

    private func updateProgress() {
        guard let startTime = measurementStartTime else { return }

        let elapsedTime = Date().timeIntervalSince(startTime)

        if elapsedTime > stabilizationTime {
            let measurementProgress = (elapsedTime - stabilizationTime) / measurementDuration
            progress = min(1.0, measurementProgress)
            status = "hg_status_measuring".localized

            if progress >= 1.0 {
                Task {
                    await finishMeasurement()
                }
            }
        }
    }

    // MARK: - PPG Data Handling
    private func handleNewPPGValue(_ value: Double) {
        guard let startTime = measurementStartTime else { return }

        let elapsedTime = Date().timeIntervalSince(startTime)

        if elapsedTime > stabilizationTime {
            let timestamp = Date().timeIntervalSince1970
            let newPoint = PPGPoint(timestamp: timestamp, value: value)

            ppgData.append(newPoint)

            // 최대 300개 포인트 유지
            if ppgData.count > 300 {
                ppgData = Array(ppgData.suffix(300))
            }

            updateRealtimeBpm()
        }
    }

    private func updateRealtimeBpm() {
        let recentData = Array(ppgData.suffix(100))

        if let bpm = heartRateAnalyzer.calculateRealtimeBpm(recentData: recentData) {
            if currentBpm == 0 {
                currentBpm = bpm
            } else {
                // 부드러운 전환을 위한 exponential moving average
                currentBpm = currentBpm * 0.8 + bpm * 0.2
            }
        }
    }

    // MARK: - Analysis
    private func finishMeasurement() async {
        stopMeasurement()
        isAnalyzing = true
        status = "hg_status_analyzing".localized

        guard ppgData.count >= 50 else {
            analysisResult = AnalysisResult(
                averageBpm: 0,
                hrv: 0,
                interpretation: "hg_error_insufficient_data".localized,
                riskLevel: .high
            )
            isAnalyzing = false
            return
        }

        guard let (bpm, hrv, riskLevel) = heartRateAnalyzer.analyze(ppgData: ppgData) else {
            analysisResult = AnalysisResult(
                averageBpm: 0,
                hrv: 0,
                interpretation: "hg_error_no_signal".localized,
                riskLevel: .high
            )
            isAnalyzing = false
            return
        }

        let interpretation = await interpretationService.getInterpretation(bpm: bpm, hrv: hrv)

        analysisResult = AnalysisResult(
            averageBpm: bpm,
            hrv: hrv,
            interpretation: interpretation,
            riskLevel: riskLevel
        )

        isAnalyzing = false
    }

    // MARK: - Reset
    func reset() {
        ppgData = []
        currentBpm = 0
        progress = 0
        status = "hg_status_initializing".localized
        error = nil
        isAnalyzing = false
        analysisResult = nil
        measurementStartTime = nil
    }
}
