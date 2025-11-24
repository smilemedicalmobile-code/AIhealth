//
//  ReservationDetailScreen.swift
//  AIhealth
//
//  Created on 2025-10-30.
//

import SwiftUI

struct ReservationDetailScreen: View {
    let reservation: Reservation
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingLarge) {
                // 상태 카드
                statusCard

                // 환자 정보
                patientInfoCard

                // 예약 정보
                reservationInfoCard

                // 증상 및 메모
                symptomsCard

                // 첨부 파일
                if !reservation.attachmentUrls.isEmpty {
                    attachmentsCard
                }
            }
            .padding()
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("reservation_detail".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // 대기 또는 확정 상태일 때만 수정 가능
                if reservation.status == .pending || reservation.status == .confirmed {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Text("edit_reservation".localized)
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                ReservationEditScreen(reservation: reservation)
            }
        }
    }

    // MARK: - Status Card
    private var statusCard: some View {
        CommonCard {
            VStack(spacing: AppTheme.spacingMedium) {
                Image(systemName: statusIcon)
                    .font(.system(size: 50))
                    .foregroundColor(statusColor)

                Text(reservation.status.displayName)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .bold))
                    .foregroundColor(statusColor)

                Text(statusDescription)
                    .font(.system(size: AppTheme.fontSizeSmall))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.spacingMedium)
        }
    }

    // MARK: - Patient Info Card
    private var patientInfoCard: some View {
        let isKorean = Locale.current.language.languageCode?.identifier == "ko"

        return CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("patient_information".localized)
                    .font(.system(size: AppTheme.fontSizeLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                // Name (common)
                InfoRow(icon: "person.fill", title: "name_placeholder".localized, value: reservation.patientName)

                if isKorean {
                    // Korean patient info
                    if !reservation.patientIdNumber.isEmpty {
                        InfoRow(icon: "number", title: "id_number_label".localized, value: reservation.patientIdNumber)
                    }
                    if !reservation.patientAddress.isEmpty {
                        InfoRow(icon: "house.fill", title: "address_label".localized, value: reservation.patientAddress)
                    }
                    if !reservation.patientPhone.isEmpty {
                        InfoRow(icon: "phone.fill", title: "phone_placeholder".localized, value: reservation.patientPhone)
                    }
                } else {
                    // International patient info
                    if !reservation.dateOfBirth.isEmpty {
                        InfoRow(icon: "calendar", title: "date_of_birth_placeholder".localized, value: reservation.dateOfBirth)
                    }
                    if !reservation.patientPhone.isEmpty {
                        InfoRow(icon: "phone.fill", title: "contact_number_placeholder".localized, value: reservation.patientPhone)
                    }
                    if !reservation.patientAddress.isEmpty {
                        InfoRow(icon: "house.fill", title: "address_in_korea_placeholder".localized, value: reservation.patientAddress)
                    }
                    if !reservation.passportNumber.isEmpty {
                        InfoRow(icon: "doc.text.fill", title: "passport_number_placeholder".localized, value: reservation.passportNumber)
                    }
                    if !reservation.passportExpiryDate.isEmpty {
                        InfoRow(icon: "calendar.badge.clock", title: "passport_expiry_placeholder".localized, value: reservation.passportExpiryDate)
                    }
                    if !reservation.email.isEmpty {
                        InfoRow(icon: "envelope.fill", title: "email_placeholder".localized, value: reservation.email)
                    }
                }
            }
        }
    }

    // MARK: - Reservation Info Card
    private var reservationInfoCard: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("reservation_information".localized)
                    .font(.system(size: AppTheme.fontSizeLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                InfoRow(icon: "building.2.fill", title: "hospital_name".localized, value: displayHospitalName.localized)
                InfoRow(icon: "map.fill", title: "region".localized, value: localizedRegion)

                if let date = reservation.preferredDate {
                    InfoRow(icon: "calendar", title: "preferred_date".localized, value: date)
                }

                if let time = reservation.preferredTime {
                    InfoRow(icon: "clock.fill", title: "preferred_time".localized, value: time)
                }

                if let department = reservation.medicalDepartment {
                    InfoRow(icon: "cross.case.fill", title: "department".localized, value: department.localized)
                }

                if let doctor = reservation.doctorName {
                    InfoRow(icon: "stethoscope", title: "doctor".localized, value: doctor)
                }
            }
        }
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

    private var localizedRegion: String {
        // 지역이 비어있으면 빈 문자열 반환
        if reservation.preferredRegion.isEmpty {
            return ""
        }

        // "서울특별시 강남구" 형태를 공백으로 분리
        let components = reservation.preferredRegion.split(separator: " ")

        // 각 부분을 로컬라이즈하고 다시 합침
        let localizedComponents = components.map { String($0).localized }
        return localizedComponents.joined(separator: " ")
    }

    // MARK: - Symptoms Card
    private var symptomsCard: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("symptoms".localized)
                    .font(.system(size: AppTheme.fontSizeLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                Text(reservation.symptoms)
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .foregroundColor(.textSecondary)

                if let notes = reservation.notes, !notes.isEmpty {
                    Divider()

                    Text("notes".localized)
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .semibold))
                        .foregroundColor(.textPrimary)

                    Text(notes)
                        .font(.system(size: AppTheme.fontSizeMedium))
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }

    // MARK: - Attachments Card
    private var attachmentsCard: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("attachments".localized)
                    .font(.system(size: AppTheme.fontSizeLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                ForEach(reservation.attachmentUrls, id: \.self) { url in
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.bluePrimary)
                        Text(url)
                            .font(.system(size: AppTheme.fontSizeSmall))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private var statusIcon: String {
        switch reservation.status {
        case .pending: return "clock.fill"
        case .confirmed: return "checkmark.circle.fill"
        case .completed: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch reservation.status {
        case .pending: return .warningColor
        case .confirmed: return .successColor
        case .completed: return .infoColor
        case .cancelled: return .errorColor
        }
    }

    private var statusDescription: String {
        switch reservation.status {
        case .pending:
            return "status_pending_desc".localized
        case .confirmed:
            return "status_confirmed_desc".localized
        case .completed:
            return "status_completed_desc".localized
        case .cancelled:
            return "status_cancelled_desc".localized
        }
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.spacingSmall) {
            Image(systemName: icon)
                .font(.system(size: AppTheme.fontSizeSmall))
                .foregroundColor(.bluePrimary)
                .frame(width: 20)

            Text(title)
                .font(.system(size: AppTheme.fontSizeSmall))
                .foregroundColor(.textSecondary)
                .frame(width: 100, alignment: .leading)

            Text(value)
                .font(.system(size: AppTheme.fontSizeMedium))
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        ReservationDetailScreen(reservation: Reservation(
            patientName: "홍길동",
            patientIdNumber: "900101-1******",
            patientAddress: "서울특별시 강남구",
            patientPhone: "010-1234-5678",
            selectedHospital: "서울대학교병원",
            symptoms: "두통과 어지러움 증상",
            preferredDate: "2025년 11월 1일",
            preferredTime: "14:00",
            medicalDepartment: "신경과",
            status: .confirmed
        ))
    }
}
