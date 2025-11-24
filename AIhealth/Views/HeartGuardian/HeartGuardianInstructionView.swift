import SwiftUI

struct HeartGuardianInstructionView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("hg_instruction_title".localized)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#1E293B"))
                .padding(.bottom, 24)

            VStack(spacing: 16) {
                InstructionCard(
                    icon: "hand.point.up.left.fill",
                    iconColor: Color(hex: "#0284C7"),
                    title: "hg_instruction_cover_camera_title".localized,
                    description: "hg_instruction_cover_camera_desc".localized
                )

                InstructionCard(
                    icon: "camera.fill",
                    iconColor: Color(hex: "#0284C7"),
                    title: "hg_instruction_allow_camera_title".localized,
                    description: "hg_instruction_allow_camera_desc".localized
                )

                InstructionCard(
                    icon: "figure.stand",
                    iconColor: Color(hex: "#0284C7"),
                    title: "hg_instruction_stay_still_title".localized,
                    description: "hg_instruction_stay_still_desc".localized
                )
            }

            Button(action: onStart) {
                Text("hg_instruction_start_button".localized)
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
