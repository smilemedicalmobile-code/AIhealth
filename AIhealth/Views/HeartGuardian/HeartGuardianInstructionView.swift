import SwiftUI

struct HeartGuardianInstructionView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("측정 방법")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#1E293B"))
                .padding(.bottom, 24)

            VStack(spacing: 16) {
                InstructionCard(
                    icon: "hand.point.up.left.fill",
                    iconColor: Color(hex: "#0284C7"),
                    title: "카메라와 플래시 가리기",
                    description: "검지손가락을 후면 카메라와 플래시에 가볍게 올려 완전히 덮어주세요."
                )

                InstructionCard(
                    icon: "camera.fill",
                    iconColor: Color(hex: "#0284C7"),
                    title: "카메라 접근 허용",
                    description: "측정을 위해 카메라 접근을 허용하라는 메시지가 표시됩니다."
                )

                InstructionCard(
                    icon: "figure.stand",
                    iconColor: Color(hex: "#0284C7"),
                    title: "움직이지 않고 조용히 있기",
                    description: "측정하는 동안 약 30초간 침착하게 움직이거나 말하지 마세요."
                )
            }

            Button(action: onStart) {
                Text("측정 시작")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#0284C7"))
                    .cornerRadius(12)
            }
            .padding(.top, 32)
        }
        .padding(32)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

struct InstructionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#334155"))

                Text(description)
                    .font(.caption)
                    .foregroundColor(Color(hex: "#64748B"))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#F1F5F9"))
        .cornerRadius(12)
    }
}
