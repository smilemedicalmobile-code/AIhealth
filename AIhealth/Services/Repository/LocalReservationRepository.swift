//
//  LocalReservationRepository.swift
//  AIhealth
//
//  Created on 2025-10-30.
//

import Foundation

class LocalReservationRepository {
    static let shared = LocalReservationRepository()

    private let reservationsKey = "com.aihealth.localReservations"

    private init() {}

    // MARK: - Local Storage

    /// Save reservation to local storage
    func saveReservation(_ reservation: Reservation) throws {
        var reservations = try getReservations()

        // Update if exists, add if new
        if let index = reservations.firstIndex(where: { $0.id == reservation.id }) {
            reservations[index] = reservation
        } else {
            reservations.append(reservation)
        }

        let encoder = JSONEncoder()
        let data = try encoder.encode(reservations)
        UserDefaults.standard.set(data, forKey: reservationsKey)
    }

    /// Get all local reservations
    func getReservations() throws -> [Reservation] {
        guard let data = UserDefaults.standard.data(forKey: reservationsKey) else {
            return []
        }

        let decoder = JSONDecoder()

        do {
            return try decoder.decode([Reservation].self, from: data)
        } catch {
            // If decoding fails (due to schema change), clear old data and return empty
            print("⚠️ Failed to decode reservations from local storage (likely due to schema change). Clearing old data.")
            print("Error: \(error)")
            clearAll()
            return []
        }
    }

    /// Delete reservation from local storage
    func deleteReservation(id: String) throws {
        var reservations = try getReservations()
        reservations.removeAll { $0.id == id }

        let encoder = JSONEncoder()
        let data = try encoder.encode(reservations)
        UserDefaults.standard.set(data, forKey: reservationsKey)
    }

    /// Update reservation status locally
    func updateReservationStatus(id: String, status: ReservationStatus) throws {
        var reservations = try getReservations()

        guard let index = reservations.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "LocalReservationRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Reservation not found"])
        }

        reservations[index].status = status

        let encoder = JSONEncoder()
        let data = try encoder.encode(reservations)
        UserDefaults.standard.set(data, forKey: reservationsKey)
    }

    /// Sync status from Firebase
    func syncReservationStatus(id: String, status: ReservationStatus) throws {
        try updateReservationStatus(id: id, status: status)
    }

    /// Clear all local reservations (for debugging)
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: reservationsKey)
    }
}
