//
//  ReservationRepository.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation

class ReservationRepository {
    private let firebaseManager = FirebaseManager.shared
    private let localRepo = LocalReservationRepository.shared

    // MARK: - Hybrid Storage Strategy

    /// Save reservation to both local and Firebase
    func saveReservation(_ reservation: Reservation) async throws -> String {
        // 1. Save to Firebase first (for hospital admin access)
        let reservationId = try await firebaseManager.saveReservation(reservation)

        // 2. Update reservation with ID and save locally
        var localReservation = reservation
        localReservation.id = reservationId
        localReservation.deviceId = DeviceManager.shared.deviceId
        try localRepo.saveReservation(localReservation)

        return reservationId
    }

    /// Get reservations from local storage (fast, offline-capable)
    func getReservations() throws -> [Reservation] {
        return try localRepo.getReservations()
    }

    /// Sync reservation statuses from Firebase
    func syncReservationStatuses() async throws {
        let localReservations = try localRepo.getReservations()

        for reservation in localReservations {
            guard let id = reservation.id else { continue }

            // Check status from Firebase
            if let firebaseStatus = try await firebaseManager.getReservationStatus(id: id) {
                // Update local storage if status changed
                if firebaseStatus != reservation.status {
                    try localRepo.syncReservationStatus(id: id, status: firebaseStatus)
                }
            }
        }
    }

    /// Update reservation status (both local and Firebase)
    func updateReservationStatus(id: String, status: ReservationStatus) async throws {
        // Update locally first (instant feedback)
        try localRepo.updateReservationStatus(id: id, status: status)

        // Then sync to Firebase
        try await firebaseManager.updateReservationStatus(id: id, status: status)
    }

    /// Delete reservation (both local and Firebase)
    func deleteReservation(id: String) async throws {
        // Delete locally first
        try localRepo.deleteReservation(id: id)

        // Then delete from Firebase
        try await firebaseManager.deleteReservation(id: id)
    }

    /// Cancel reservation (update status to cancelled)
    func cancelReservation(id: String) async throws {
        try await updateReservationStatus(id: id, status: .cancelled)
    }

    /// Upload files to Firebase Storage
    func uploadFiles(files: [(data: Data, name: String)], userName: String) async throws -> [String] {
        return try await firebaseManager.uploadFiles(files: files, userName: userName)
    }
}
