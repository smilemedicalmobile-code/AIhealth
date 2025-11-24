//
//  DashboardHomeScreen.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI

struct DashboardHomeScreen: View {
    @StateObject private var reportViewModel = ReportViewModel()
    @EnvironmentObject var tabManager: TabNavigationManager

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLarge) {
                // Header
                headerSection

                // Main Actions
                mainActionsSection

                // Stats
                statsSection

                // Recent Consultations
                recentConsultationsSection

                // Help Section
                helpSection
            }
            .padding()
        }
        .background(Color.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                EmptyView()
            }
        }
        .onAppear {
            reportViewModel.loadDiagnosisRecords()
            reportViewModel.loadReservations()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
            // 웰컴 메시지
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.bluePrimary, Color.mintAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("home_title".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mainActionsSection: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            FeatureCard(
                icon: "stethoscope",
                title: "ai_consultation_with_reservation".localized,
                description: "ai_consultation_description".localized
            ) {
                tabManager.selectedTab = 1
            }

            FeatureCard(
                icon: "calendar.badge.plus",
                title: "direct_reservation".localized,
                description: "direct_reservation_description".localized
            ) {
                tabManager.selectedTab = 2
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
            Text("my_health_records".localized)
                .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                .foregroundColor(.textPrimary)

            HStack(spacing: AppTheme.spacingMedium) {
                Button(action: {
                    tabManager.selectedTab = 3
                }) {
                    StatCard(
                        title: "diagnosis_records".localized,
                        value: "\(reportViewModel.diagnosisRecords.count)",
                        icon: "doc.text.fill",
                        color: .bluePrimary
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    tabManager.selectedTab = 3
                }) {
                    StatCard(
                        title: "reservations".localized,
                        value: "\(reportViewModel.reservations.count)",
                        icon: "calendar.badge.clock",
                        color: .mintAccent
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var recentConsultationsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
            HStack {
                Text("recent_consultations".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                Spacer()

                Button(action: {
                    tabManager.selectedTab = 3
                }) {
                    Text("view_all".localized)
                        .font(.system(size: AppTheme.fontSizeMedium))
                        .foregroundColor(.bluePrimary)
                }
            }

            if reportViewModel.diagnosisRecords.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: AppTheme.spacingSmall) {
                    ForEach(reportViewModel.diagnosisRecords.prefix(3)) { record in
                        DiagnosisRecordRow(record: record)
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.textTertiary)

            Text("no_consultations_yet".localized)
                .font(.system(size: AppTheme.fontSizeMedium))
                .foregroundColor(.textSecondary)

            Text("start_ai_consultation".localized)
                .font(.system(size: AppTheme.fontSizeSmall))
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.spacingXLarge)
        .background(Color.blueLight)
        .cornerRadius(AppTheme.cornerRadiusMedium)
    }

    private var helpSection: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.infoColor)
                    Text("help".localized)
                        .font(.system(size: AppTheme.fontSizeLarge, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }

                VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                    HelpItem(icon: "1.circle.fill", text: "help_step_1".localized)
                    HelpItem(icon: "2.circle.fill", text: "help_step_2".localized)
                    HelpItem(icon: "3.circle.fill", text: "help_step_3".localized)
                }
            }
        }
    }
}

struct DiagnosisRecordRow: View {
    let record: DiagnosisRecord

    var body: some View {
        NavigationLink(destination: ReportPreviewScreen(summary: record.summary)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.symptoms.prefix(50) + (record.symptoms.count > 50 ? "..." : ""))
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    Text(formatDate(record.date))
                        .font(.system(size: AppTheme.fontSizeSmall))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
            .padding(AppTheme.spacingMedium)
            .background(Color.backgroundSecondary)
            .cornerRadius(AppTheme.cornerRadiusMedium)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
}

struct HelpItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: AppTheme.spacingSmall) {
            Image(systemName: icon)
                .foregroundColor(.bluePrimary)
                .frame(width: 24)

            Text(text)
                .font(.system(size: AppTheme.fontSizeMedium))
                .foregroundColor(.textSecondary)
        }
    }
}

#Preview {
    DashboardHomeScreen()
}
