import SwiftUI

struct HeartGuardianResultView: View {
    let result: AnalysisResult
    let onRestart: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("분석 결과")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#1E293B"))

                // 결과 카드들
                HStack(spacing: 12) {
                    ResultCard(
                        title: "평균 심박수",
                        value: String(format: "%.1f", result.averageBpm),
                        unit: "BPM",
                        color: Color(hex: "#0284C7")
                    )

                    ResultCard(
                        title: "심박 변이도",
                        value: String(format: "%.1f", result.hrv),
                        unit: "ms",
                        color: Color(hex: "#0284C7")
                    )
                }

                ResultCard(
                    title: "모의 위험도",
                    value: result.riskLevel.localizedString,
                    unit: "",
                    color: riskLevelColor(result.riskLevel),
                    isRiskLevel: true
                )

                // AI 해석
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI 해석")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#0C4A6E"))

                    Text(result.interpretation)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#334155"))
                        .lineSpacing(4)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#E0F2FE"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "#7DD3FC"), lineWidth: 1)
                )

                // 다시 측정하기 버튼
                Button(action: onRestart) {
                    Text("다시 측정하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#475569"))
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }

    private func riskLevelColor(_ level: RiskLevel) -> Color {
        switch level {
        case .low:
            return Color.green
        case .moderate:
            return Color.yellow
        case .high:
            return Color.red
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    var isRiskLevel: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color(hex: "#94A3B8"))

            if isRiskLevel {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(color)
                    .cornerRadius(20)
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(color)

                    Text(unit)
                        .font(.subheadline)
                        .foregroundColor(color)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(hex: "#F1F5F9"))
        .cornerRadius(12)
    }
}
