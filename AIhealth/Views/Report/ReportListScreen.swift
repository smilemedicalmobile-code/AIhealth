//
//  ReportListScreen.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI

struct ReportListScreen: View {
    @StateObject private var viewModel = ReportViewModel()
    @State private var showDeleteAlert = false
    @State private var recordToDelete: DiagnosisRecord?
    @State private var showCancelAlert = false
    @State private var showDeleteReservationAlert = false
    @State private var reservationToAction: Reservation?

    var body: some View {
        List {
            if viewModel.diagnosisRecords.isEmpty {
                emptyStateSection
            } else {
                diagnosisSection
            }

            reservationSection
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("records_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadDiagnosisRecords()
            viewModel.loadReservations()
        }
        .alert("delete_record".localized, isPresented: $showDeleteAlert) {
            Button("cancel".localized, role: .cancel) {
                recordToDelete = nil
            }
            Button("delete".localized, role: .destructive) {
                if let record = recordToDelete {
                    viewModel.deleteDiagnosisRecord(id: record.id)
                    recordToDelete = nil
                }
            }
        } message: {
            Text("delete_record_message".localized)
        }
        .alert("cancel_reservation".localized, isPresented: $showCancelAlert) {
            Button("cancel".localized, role: .cancel) {
                reservationToAction = nil
            }
            Button("cancel_reservation".localized, role: .destructive) {
                if let reservation = reservationToAction, let id = reservation.id {
                    viewModel.cancelReservation(id: id)
                    reservationToAction = nil
                }
            }
        } message: {
            Text("cancel_reservation_message".localized)
        }
        .alert("delete_reservation".localized, isPresented: $showDeleteReservationAlert) {
            Button("cancel".localized, role: .cancel) {
                reservationToAction = nil
            }
            Button("delete".localized, role: .destructive) {
                if let reservation = reservationToAction, let id = reservation.id {
                    viewModel.deleteReservation(id: id)
                    reservationToAction = nil
                }
            }
        } message: {
            Text("delete_reservation_message".localized)
        }
    }

    private var emptyStateSection: some View {
        Section {
            VStack(spacing: AppTheme.spacingMedium) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.textTertiary)

                Text("no_diagnosis_records".localized)
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.spacingXLarge)
        }
    }

    private var diagnosisSection: some View {
        Section {
            ForEach(viewModel.diagnosisRecords) { record in
                NavigationLink(destination: ReportPreviewScreen(summary: record.summary)) {
                    DiagnosisRecordListRow(record: record)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        recordToDelete = record
                        showDeleteAlert = true
                    } label: {
                        Label("delete".localized, systemImage: "trash")
                    }
                }
            }
        } header: {
            Text("diagnosis_records_tab".localized)
        }
    }

    private var reservationSection: some View {
        Section {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if viewModel.reservations.isEmpty {
                Text("no_reservations".localized)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(viewModel.reservations) { reservation in
                    NavigationLink(destination: ReservationDetailScreen(reservation: reservation)) {
                        ReservationListRow(reservation: reservation)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            // 완전 삭제 버튼
                            Button(role: .destructive) {
                                reservationToAction = reservation
                                showDeleteReservationAlert = true
                            } label: {
                                Label("delete".localized, systemImage: "trash")
                            }
                            .tint(.red)

                            // 예약 취소 버튼 (pending, confirmed 상태일 때만)
                            if reservation.status == .pending || reservation.status == .confirmed {
                                Button {
                                    reservationToAction = reservation
                                    showCancelAlert = true
                                } label: {
                                    Label("cancel_reservation".localized, systemImage: "xmark.circle")
                                }
                                .tint(.orange)
                            }
                        }
                }
            }
        } header: {
            Text("reservations_tab".localized)
        }
    }
}

struct DiagnosisRecordListRow: View {
    let record: DiagnosisRecord

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
            // AI 요약의 첫 줄을 제목으로 사용
            Text(extractTitle(from: record.summary))
                .font(.system(size: AppTheme.fontSizeMedium, weight: .semibold))
                .foregroundColor(.textPrimary)
                .lineLimit(2)

            // 증상을 부제목으로 표시
            Text(record.symptoms)
                .font(.system(size: AppTheme.fontSizeSmall))
                .foregroundColor(.textSecondary)
                .lineLimit(1)

            HStack(spacing: AppTheme.spacingMedium) {
                // 날짜
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: AppTheme.fontSizeSmall))
                    Text(String(formatDate(record.date).split(separator: " ")[0]))
                        .font(.system(size: AppTheme.fontSizeSmall))
                }
                .foregroundColor(.textSecondary)

                // 시간
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: AppTheme.fontSizeSmall))
                    Text(String(formatDate(record.date).split(separator: " ")[1]))
                        .font(.system(size: AppTheme.fontSizeSmall))
                }
                .foregroundColor(.textSecondary)
            }
        }
        .padding(.vertical, AppTheme.spacingXSmall)
    }

    private func extractTitle(from summary: String) -> String {
        // AI 요약의 첫 줄 또는 첫 50자를 제목으로 사용
        let lines = summary.components(separatedBy: .newlines)
        let firstLine = lines.first ?? summary

        if firstLine.count > 50 {
            let index = firstLine.index(firstLine.startIndex, offsetBy: 50)
            return String(firstLine[..<index]) + "..."
        }
        return firstLine
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}

struct ReservationListRow: View {
    let reservation: Reservation

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
            HStack {
                Text(displayHospitalName)
                    .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                    .foregroundColor(.textPrimary)

                Spacer()

                statusBadge
            }

            Text(reservation.symptoms)
                .font(.system(size: AppTheme.fontSizeSmall))
                .foregroundColor(.textSecondary)
                .lineLimit(1)

            HStack(spacing: AppTheme.spacingMedium) {
                // 날짜
                if let date = reservation.preferredDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: AppTheme.fontSizeSmall))
                        Text(date)
                            .font(.system(size: AppTheme.fontSizeSmall))
                    }
                    .foregroundColor(.textSecondary)
                }

                // 시간
                if let time = reservation.preferredTime {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: AppTheme.fontSizeSmall))
                        Text(time)
                            .font(.system(size: AppTheme.fontSizeSmall))
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.vertical, AppTheme.spacingXSmall)
    }

    private var displayHospitalName: String {
        // 개인병원인 경우 병원명이 비어있으면 플레이스홀더 표시
        if reservation.hospitalType == .private_ {
            if reservation.selectedHospital.isEmpty {
                return "private_hospital_name_placeholder".localized
            }
        }

        // 병원명이 있으면 그대로 표시
        if !reservation.selectedHospital.isEmpty {
            return reservation.selectedHospital
        }

        // 그 외의 경우 "병원 미선택"
        return "no_hospital_selected".localized
    }

    private var statusBadge: some View {
        Text(reservation.status.displayName)
            .font(.system(size: AppTheme.fontSizeSmall, weight: .semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(AppTheme.cornerRadiusSmall)
    }

    private var statusColor: Color {
        switch reservation.status {
        case .pending:
            return .warningColor
        case .confirmed:
            return .successColor
        case .completed:
            return .infoColor
        case .cancelled:
            return .errorColor
        }
    }
}

#Preview {
    NavigationStack {
        ReportListScreen()
    }
}
