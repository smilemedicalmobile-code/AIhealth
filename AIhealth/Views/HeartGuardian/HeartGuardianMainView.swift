import SwiftUI

enum MeasurementState {
    case instruction
    case measuring
    case result
}

struct HeartGuardianMainView: View {
    @StateObject private var viewModel = HeartGuardianViewModel()
    @State private var measurementState: MeasurementState = .instruction

    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#F0F9FF"),
                    Color(hex: "#E0F2FE")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // 헤더
                    HeaderView()
                        .padding(.top, 20)

                    // 콘텐츠
                    switch measurementState {
                    case .instruction:
                        HeartGuardianInstructionView {
                            startMeasurement()
                        }

                    case .measuring:
                        HeartGuardianMeasurementView(viewModel: viewModel)

                    case .result:
                        if let result = viewModel.analysisResult {
                            HeartGuardianResultView(result: result) {
                                restartMeasurement()
                            }
                        }
                    }

                    // 면책 조항
                    DisclaimerView()
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 16)
            }
        }
        .onChange(of: viewModel.analysisResult) { result in
            if result != nil {
                measurementState = .result
            }
        }
    }

    private func startMeasurement() {
        measurementState = .measuring
        Task {
            await viewModel.startMeasurement()
        }
    }

    private func restartMeasurement() {
        viewModel.reset()
        measurementState = .instruction
    }
}

struct HeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "#F43F5E"))

            Text("하트 가디언")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#1E293B"))
        }
    }
}

struct DisclaimerView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Color(hex: "#D97706"))
                .font(.title3)

            VStack(alignment: .leading, spacing: 8) {
                Text("중요 면책 조항")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#92400E"))

                Text("이 애플리케이션은 정보 제공 및 교육 목적으로만 사용됩니다. 의료 기기가 아니며 자가 진단이나 전문적인 의학적 조언, 진단 또는 치료를 대신하는 용도로 사용해서는 안 됩니다. 건강에 대한 우려가 있는 경우 자격을 갖춘 의료 전문가와 상담하십시오.")
                    .font(.caption2)
                    .foregroundColor(Color(hex: "#78350F"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(Color(hex: "#FEF3C7"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#FDE68A"), lineWidth: 1)
        )
    }
}
