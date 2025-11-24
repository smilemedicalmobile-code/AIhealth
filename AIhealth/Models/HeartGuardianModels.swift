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
            return "hg_risk_low".localized
        case .moderate:
            return "hg_risk_moderate".localized
        case .high:
            return "hg_risk_high".localized
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
struct AnalysisResult: Equatable {
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
