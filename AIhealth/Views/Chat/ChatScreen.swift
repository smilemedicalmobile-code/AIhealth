//
//  ChatScreen.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI

struct ChatScreen: View {
    @ObservedObject var viewModel = ChatViewModel.shared
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToReportPreview = false

    var body: some View {
        VStack(spacing: 0) {
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: AppTheme.spacingMedium) {
                        ForEach(viewModel.messages) { message in
                            ChatMessageBubble(message: message)
                                .id(message.id)
                        }

                        if viewModel.isLoading {
                            HStack {
                                TypingIndicatorBubble()
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                .onTapGesture {
                    // 빈 공간 터치 시 키보드 내리기
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input Area
            VStack(spacing: 0) {
                // End Consultation Button (위에 배치)
                if viewModel.messages.count > 2 && !viewModel.isGeneratingSummary {
                    Button(action: {
                        viewModel.endConsultationAndGenerateSummary()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 16))
                            Text("save_and_view_summary".localized)
                                .font(.system(size: AppTheme.fontSizeMedium, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.bluePrimary, Color.mintAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background(Color.backgroundSecondary)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Summary Generation Loading
                if viewModel.isGeneratingSummary {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .bluePrimary))
                            .scaleEffect(1.2)

                        Text("generating_summary".localized)
                            .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                            .foregroundColor(.textPrimary)

                        Text("please_wait".localized)
                            .font(.system(size: AppTheme.fontSizeSmall))
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.blueLight)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .transition(.scale.combined(with: .opacity))
                }

                // Error Message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: AppTheme.fontSizeSmall))
                        .foregroundColor(.errorColor)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }

                // Medical Disclaimer
                DisclaimerBanner()

                // Input Field
                HStack(spacing: AppTheme.spacingSmall) {
                    TextField("type_message_placeholder".localized, text: $viewModel.currentMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(viewModel.isLoading || viewModel.isGeneratingSummary)

                    Button(action: {
                        viewModel.sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(viewModel.currentMessage.isEmpty ? .textTertiary : .bluePrimary)
                    }
                    .disabled(viewModel.currentMessage.isEmpty || viewModel.isLoading || viewModel.isGeneratingSummary)
                }
                .padding()
                .background(Color.backgroundSecondary)
            }
        }
        .navigationTitle("ai_health_consultation".localized)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.backgroundPrimary)
        .onChange(of: viewModel.generatedSummary) { summary in
            if summary != nil {
                navigateToReportPreview = true
            }
        }
        .navigationDestination(isPresented: $navigateToReportPreview) {
            if let summary = viewModel.generatedSummary {
                ReportPreviewScreen(summary: summary)
            }
        }
        .onAppear {
            // Initial greeting message
            if viewModel.messages.isEmpty {
                let greeting = ChatMessage(
                    isUser: false,
                    message: "greeting_message".localized
                )
                viewModel.messages.append(greeting)
            }
        }
    }
}

struct ChatMessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 50)
                messageBubble
                    .background(
                        LinearGradient(
                            colors: [Color.bluePrimary, Color.bluePrimary.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
            } else {
                // AI 아이콘
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.mintAccent, Color.bluePrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "stethoscope")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    )

                messageBubble
                    .background(Color.backgroundSecondary)
                    .foregroundColor(.textPrimary)
                Spacer(minLength: 50)
            }
        }
    }

    private var messageBubble: some View {
        Text(message.message)
            .font(.system(size: AppTheme.fontSizeMedium))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.clear)
            )
            .clipShape(
                BubbleShape(isFromCurrentUser: message.isUser)
            )
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 2
            )
    }
}

// Custom bubble shape with tail
struct BubbleShape: Shape {
    let isFromCurrentUser: Bool

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: isFromCurrentUser
                ? [.topLeft, .topRight, .bottomLeft]
                : [.topLeft, .topRight, .bottomRight],
            cornerRadii: CGSize(width: 20, height: 20)
        )
        return Path(path.cgPath)
    }
}

// AI 타이핑 인디케이터를 말풍선 형태로
struct TypingIndicatorBubble: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // AI 아이콘
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.mintAccent, Color.bluePrimary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "stethoscope")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                )

            HStack(spacing: 8) {
                TypingIndicator()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.backgroundSecondary)
            .clipShape(
                BubbleShape(isFromCurrentUser: false)
            )
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 8,
                x: 0,
                y: 2
            )
        }
        .padding(.leading, 8)
    }
}

// Medical Disclaimer Banner
struct DisclaimerBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("medical_disclaimer_title".localized)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textPrimary)
            }

            Text("medical_disclaimer_text".localized)
                .font(.system(size: 10))
                .foregroundColor(.textSecondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.08))
        .cornerRadius(8)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ChatScreen()
    }
}
