//
//  ReservationEditScreen.swift
//  AIhealth
//
//  Created on 2025-10-30.
//

import SwiftUI

struct ReservationEditScreen: View {
    let reservation: Reservation
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ReservationViewModel

    init(reservation: Reservation) {
        self.reservation = reservation
        _viewModel = StateObject(wrappedValue: ReservationViewModel(editingReservation: reservation))
    }

    var body: some View {
        let isKorean = Locale.current.language.languageCode?.identifier == "ko"

        ZStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingLarge) {
                    // 수정 불가 안내
                    infoCard

                    // 환자 정보 수정
                    patientInfoSection(isKorean: isKorean)

                    // 증상 수정
                    symptomsSection

                    // 메모 수정
                    notesSection

                    // 희망 날짜/시간 수정
                    dateTimeSection

                    // 저장 버튼
                    saveButton
                }
                .padding()
            }
            .background(Color.backgroundPrimary)

            if viewModel.isLoading {
                LoadingOverlay(message: "updating_reservation".localized)
            }
        }
        .navigationTitle("edit_reservation".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("cancel".localized) {
                    dismiss()
                }
            }
        }
        .alert("success".localized, isPresented: .constant(viewModel.successMessage != nil)) {
            Button("confirm".localized) {
                viewModel.successMessage = nil
                dismiss()
            }
        } message: {
            if let message = viewModel.successMessage {
                Text(message)
            }
        }
        .alert("error".localized, isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("confirm".localized) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Info Card
    private var infoCard: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingSmall) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.infoColor)
                    Text("editable_fields".localized)
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }

                Text("edit_info_message".localized)
                    .font(.system(size: AppTheme.fontSizeSmall))
                    .foregroundColor(.textSecondary)
            }
        }
    }

    // MARK: - Patient Info Section
    private func patientInfoSection(isKorean: Bool) -> some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("patient_info".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                // Name (common)
                VStack(alignment: .leading, spacing: 8) {
                    Text("name_placeholder".localized)
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                        .foregroundColor(.textSecondary)

                    TextField("name_placeholder".localized, text: $viewModel.reservation.patientName)
                        .font(.system(size: AppTheme.fontSizeMedium))
                        .padding(AppTheme.spacingMedium)
                        .background(Color.backgroundSecondary)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                }

                if isKorean {
                    // Korean fields
                    VStack(alignment: .leading, spacing: 8) {
                        Text("id_number_placeholder".localized)
                            .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                            .foregroundColor(.textSecondary)

                        TextField("id_number_placeholder".localized, text: $viewModel.reservation.patientIdNumber)
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .padding(AppTheme.spacingMedium)
                            .background(Color.backgroundSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("address_placeholder".localized)
                            .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                            .foregroundColor(.textSecondary)

                        TextField("address_placeholder".localized, text: $viewModel.reservation.patientAddress)
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .padding(AppTheme.spacingMedium)
                            .background(Color.backgroundSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("phone_placeholder".localized)
                            .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                            .foregroundColor(.textSecondary)

                        TextField("phone_placeholder".localized, text: $viewModel.reservation.patientPhone)
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .keyboardType(.phonePad)
                            .padding(AppTheme.spacingMedium)
                            .background(Color.backgroundSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }
                } else {
                    // English fields
                    VStack(alignment: .leading, spacing: 8) {
                        Text("date_of_birth_placeholder".localized)
                            .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                            .foregroundColor(.textSecondary)

                        TextField("date_of_birth_placeholder".localized, text: $viewModel.reservation.dateOfBirth)
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .padding(AppTheme.spacingMedium)
                            .background(Color.backgroundSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("contact_number_placeholder".localized)
                            .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                            .foregroundColor(.textSecondary)

                        TextField("contact_number_placeholder".localized, text: $viewModel.reservation.patientPhone)
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .keyboardType(.phonePad)
                            .padding(AppTheme.spacingMedium)
                            .background(Color.backgroundSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("address_in_korea_placeholder".localized)
                            .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                            .foregroundColor(.textSecondary)

                        TextField("address_in_korea_placeholder".localized, text: $viewModel.reservation.patientAddress)
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .padding(AppTheme.spacingMedium)
                            .background(Color.backgroundSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("passport_number_placeholder".localized)
                            .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                            .foregroundColor(.textSecondary)

                        TextField("passport_number_placeholder".localized, text: $viewModel.reservation.passportNumber)
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .padding(AppTheme.spacingMedium)
                            .background(Color.backgroundSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("passport_expiry_placeholder".localized)
                            .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                            .foregroundColor(.textSecondary)

                        TextField("passport_expiry_placeholder".localized, text: $viewModel.reservation.passportExpiryDate)
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .padding(AppTheme.spacingMedium)
                            .background(Color.backgroundSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("email_placeholder".localized)
                            .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                            .foregroundColor(.textSecondary)

                        TextField("email_placeholder".localized, text: $viewModel.reservation.email)
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .keyboardType(.emailAddress)
                            .padding(AppTheme.spacingMedium)
                            .background(Color.backgroundSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                    }
                }
            }
        }
    }

    // MARK: - Symptoms Section
    private var symptomsSection: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("symptoms".localized)
                    .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                    .foregroundColor(.textSecondary)

                TextField("main_symptoms".localized, text: $viewModel.reservation.symptoms, axis: .vertical)
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .textFieldStyle(.plain)
                    .padding(AppTheme.spacingMedium)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                    .lineLimit(4...10)
            }
        }
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("notes".localized)
                    .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                    .foregroundColor(.textSecondary)

                TextField("additional_notes".localized, text: Binding(
                    get: { viewModel.reservation.notes ?? "" },
                    set: { viewModel.reservation.notes = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .textFieldStyle(.plain)
                    .padding(AppTheme.spacingMedium)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
                    .lineLimit(2...5)
            }
        }
    }

    // MARK: - Date/Time Section
    private var dateTimeSection: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("preferred_date".localized)
                    .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                    .foregroundColor(.textSecondary)

                TextField("select_date".localized, text: Binding(
                    get: { viewModel.reservation.preferredDate ?? "" },
                    set: { viewModel.reservation.preferredDate = $0.isEmpty ? nil : $0 }
                ))
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .padding(AppTheme.spacingMedium)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(AppTheme.cornerRadiusMedium)

                Text("preferred_time".localized)
                    .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                    .foregroundColor(.textSecondary)

                TextField("select_time".localized, text: Binding(
                    get: { viewModel.reservation.preferredTime ?? "" },
                    set: { viewModel.reservation.preferredTime = $0.isEmpty ? nil : $0 }
                ))
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .padding(AppTheme.spacingMedium)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(AppTheme.cornerRadiusMedium)
            }
        }
    }

    // MARK: - Save Button
    private var saveButton: some View {
        CommonButton(
            title: "save".localized,
            variant: .primary,
            action: {
                viewModel.updateReservation()
            }
        )
    }
}
