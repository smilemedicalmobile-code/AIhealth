import Foundation

class HeartRateAnalyzer {
    func analyze(ppgData: [PPGPoint]) -> (averageBpm: Double, hrv: Double, riskLevel: RiskLevel)? {
        guard ppgData.count >= 50 else {
            return nil
        }

        let signal = ppgData.map { $0.value }
        let timestamps = ppgData.map { $0.timestamp }

        // Peak detection
        let peaks = detectPeaks(signal: signal, timestamps: timestamps)

        guard peaks.count >= 5 else {
            return nil
        }

        // RR intervals 계산
        var rrIntervals: [Double] = []
        for i in 1..<peaks.count {
            let interval = timestamps[peaks[i]] - timestamps[peaks[i-1]]
            rrIntervals.append(interval * 1000) // milliseconds
        }

        // 평균 BPM 계산
        let avgRR = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        let averageBpm = 60000 / avgRR

        // HRV 계산 (SDNN - Standard Deviation of NN intervals)
        let meanRR = rrIntervals.reduce(0, +) / Double(rrIntervals.count)
        let variance = rrIntervals.map { pow($0 - meanRR, 2) }.reduce(0, +) / Double(rrIntervals.count - 1)
        let hrv = sqrt(variance)

        // 위험도 평가
        let riskLevel = assessRisk(bpm: averageBpm, hrv: hrv)

        return (averageBpm, hrv, riskLevel)
    }

    private func detectPeaks(signal: [Double], timestamps: [TimeInterval]) -> [Int] {
        var peaks: [Int] = []
        let mean = signal.reduce(0, +) / Double(signal.count)

        for i in 1..<(signal.count - 1) {
            if signal[i] > signal[i-1] && signal[i] > signal[i+1] && signal[i] > mean {
                peaks.append(i)
            }
        }

        return peaks
    }

    private func assessRisk(bpm: Double, hrv: Double) -> RiskLevel {
        if bpm < 50 || bpm > 110 || hrv < 20 {
            return .high
        } else if (bpm < 60 || bpm > 100) || hrv < 40 {
            return .moderate
        } else {
            return .low
        }
    }

    func calculateRealtimeBpm(recentData: [PPGPoint]) -> Double? {
        guard recentData.count >= 2 else { return nil }

        let signal = recentData.map { $0.value }
        let timestamps = recentData.map { $0.timestamp }
        let mean = signal.reduce(0, +) / Double(signal.count)

        var peaks: [Int] = []
        for i in 1..<(signal.count - 1) {
            if signal[i] > signal[i-1] && signal[i] > signal[i+1] && signal[i] > mean {
                peaks.append(i)
            }
        }

        guard peaks.count > 2 else { return nil }

        let lastPeakTime = timestamps[peaks[peaks.count - 1]]
        let firstPeakTime = timestamps[peaks[0]]
        let durationSeconds = lastPeakTime - firstPeakTime
        let currentBpm = Double(peaks.count - 1) / durationSeconds * 60

        if currentBpm > 40 && currentBpm < 200 {
            return currentBpm
        }

        return nil
    }
}
