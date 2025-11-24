import SwiftUI
import Charts

struct HeartGuardianMeasurementView: View {
    @ObservedObject var viewModel: HeartGuardianViewModel

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isAnalyzing {
                AnalyzingView(status: viewModel.status)
            } else if let error = viewModel.error {
                ErrorView(error: error)
            } else {
                MeasurementContentView(viewModel: viewModel)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

struct AnalyzingView: View {
    let status: String

    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)

            Text(status)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#334155"))
        }
        .frame(height: 400)
    }
}

struct ErrorView: View {
    let error: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)

            Text("측정 오류")
                .font(.headline)
                .foregroundColor(.red)

            Text(error)
                .font(.subheadline)
                .foregroundColor(Color(hex: "#64748B"))
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(height: 400)
    }
}

struct MeasurementContentView: View {
    @ObservedObject var viewModel: HeartGuardianViewModel

    var body: some View {
        VStack(spacing: 16) {
            // 상태 표시
            HStack {
                Spacer()
                Text(viewModel.status)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
            }

            // BPM 및 진행률
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", viewModel.currentBpm))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: "#EF4444"))

                    Text("BPM")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#94A3B8"))
                }

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: viewModel.progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#0284C7")))
                        .frame(width: 150)

                    Text("\(Int(viewModel.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#64748B"))
                }
            }
            .padding(.vertical, 16)

            // PPG 신호 그래프
            PPGChartView(ppgData: viewModel.ppgData)
                .frame(height: 200)
                .padding(.vertical, 16)

            // 측정 안내
            Text("손가락을 움직이지 말고 카메라를 완전히 덮어주세요")
                .font(.caption)
                .foregroundColor(Color(hex: "#64748B"))
                .multilineTextAlignment(.center)
        }
    }
}

struct PPGChartView: View {
    let ppgData: [PPGPoint]

    var body: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(ppgData) { point in
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(Color(hex: "#EF4444"))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: .automatic)
        } else {
            // iOS 15 이하에서는 간단한 플레이스홀더
            Rectangle()
                .fill(Color(hex: "#F1F5F9"))
                .overlay(
                    Text("PPG 신호")
                        .foregroundColor(Color(hex: "#94A3B8"))
                )
        }
    }
}
