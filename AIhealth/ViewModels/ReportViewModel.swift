//
//  ReportViewModel.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation
import Combine

@MainActor
class ReportViewModel: ObservableObject {
    @Published var diagnosisRecords: [DiagnosisRecord] = []
    @Published var reservations: [Reservation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let diagnosisRepository = DiagnosisRepository()
    private let reservationRepository = ReservationRepository()

    func loadDiagnosisRecords() {
        diagnosisRecords = diagnosisRepository.getAllDiagnosisRecords()
            .sorted { $0.date > $1.date }
    }

    func loadReservations() {
        // Load from local storage first (instant)
        do {
            reservations = try reservationRepository.getReservations()
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            errorMessage = "예약 목록을 불러오는 중 오류가 발생했습니다: \(error.localizedDescription)"
        }

        // Then sync statuses from Firebase in background
        Task {
            await syncReservationStatuses()
        }
    }

    private func syncReservationStatuses() async {
        do {
            try await reservationRepository.syncReservationStatuses()

            // Reload from local storage after sync
            reservations = try reservationRepository.getReservations()
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            // Silent fail - offline mode still works
            print("Failed to sync reservation statuses: \(error.localizedDescription)")
        }
    }

    func deleteDiagnosisRecord(id: String) {
        do {
            try diagnosisRepository.deleteDiagnosisRecord(id: id)
            loadDiagnosisRecords()
        } catch {
            errorMessage = "기록 삭제 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }

    func getDiagnosisRecord(id: String) -> DiagnosisRecord? {
        return diagnosisRepository.getDiagnosisRecord(id: id)
    }

    // MARK: - Reservation Actions
    func cancelReservation(id: String) {
        Task {
            await cancelReservationAsync(id: id)
        }
    }

    private func cancelReservationAsync(id: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await reservationRepository.cancelReservation(id: id)
            // Reload from local storage
            reservations = try reservationRepository.getReservations()
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            errorMessage = "예약 취소 중 오류가 발생했습니다: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func deleteReservation(id: String) {
        Task {
            await deleteReservationAsync(id: id)
        }
    }

    private func deleteReservationAsync(id: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await reservationRepository.deleteReservation(id: id)
            // Reload from local storage
            reservations = try reservationRepository.getReservations()
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            errorMessage = "예약 삭제 중 오류가 발생했습니다: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
