//
//  ReportPreviewScreen.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI

struct ReportPreviewScreen: View {
    let summary: String
    @State private var navigateToReservation = false
    @State private var showPDFExportAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLarge) {
                // Header
                headerSection

                // Report Content
                reportContentSection

                // Actions
                actionsSection
            }
            .padding()
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("consultation_result".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToReservation) {
            ReservationScreen(reportSummary: summary)
        }
        .alert("pdf_generation".localized, isPresented: $showPDFExportAlert) {
            Button("confirm".localized) {
                showPDFExportAlert = false
            }
        } message: {
            Text("pdf_feature_not_implemented".localized)
        }
    }

    private var headerSection: some View {
        CommonCard(useGradient: true) {
            VStack(spacing: AppTheme.spacingMedium) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.successColor)

                Text("consultation_completed".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .bold))
                    .foregroundColor(.textPrimary)

                Text("ai_consultation_result_description".localized)
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var reportContentSection: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("consultation_result".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                Divider()

                Text(summary)
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .foregroundColor(.textPrimary)
                    .lineSpacing(6)
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: AppTheme.spacingMedium) {
            Text("next_steps".localized)
                .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            CommonButton(
                title: "make_hospital_reservation".localized,
                variant: .primary,
                action: {
                    navigateToReservation = true
                }
            )

            CommonButton(
                title: "save_as_pdf".localized,
                variant: .outlined,
                action: {
                    showPDFExportAlert = true
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        ReportPreviewScreen(summary: """
        ## 주요 증상
        - 두통
        - 어지러움

        ## 상담 내용 요약
        환자는 3일 전부터 지속적인 두통과 간헐적인 어지러움을 호소하고 있습니다.

        ## 권장 사항
        - 추천 진료과: 신경과
        - 충분한 수분 섭취 권장
        - 스트레스 관리 필요
        """)
    }
}
