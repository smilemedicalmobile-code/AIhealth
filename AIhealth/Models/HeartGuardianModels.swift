import Foundation

// MARK: - PPG Data Point
struct PPGPoint: Identifiable {
    let id = UUID()
    let timestamp: TimeInterval
    let value: Double
}

// MARK: - Risk Level
enum RiskLevel: String, Codable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"

    var localizedString: String {
        switch self {
        case .low:
            return "낮음"
        case .moderate:
            return "보통"
        case .high:
            return "높음"
        }
    }

    var color: String {
        switch self {
        case .low:
            return "green"
        case .moderate:
            return "yellow"
        case .high:
            return "red"
        }
    }
}

// MARK: - Analysis Result
struct AnalysisResult {
    let averageBpm: Double
    let hrv: Double
    let interpretation: String
    let riskLevel: RiskLevel
    let timestamp: Date

    init(averageBpm: Double, hrv: Double, interpretation: String, riskLevel: RiskLevel, timestamp: Date = Date()) {
        self.averageBpm = averageBpm
        self.hrv = hrv
        self.interpretation = interpretation
        self.riskLevel = riskLevel
        self.timestamp = timestamp
    }
}
