//
//  FirebaseManager.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseRemoteConfig

class FirebaseManager {
    static let shared = FirebaseManager()

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let remoteConfig = RemoteConfig.remoteConfig()

    private init() {
        configureRemoteConfig()
    }

    // MARK: - Remote Config
    private func configureRemoteConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1 hour
        remoteConfig.configSettings = settings

        // Set default values
        remoteConfig.setDefaults(["openai_api_key": "" as NSObject])
    }

    func fetchRemoteConfig() async throws {
        let status = try await remoteConfig.fetch()
        if status == .success {
            try await remoteConfig.activate()
        }
    }

    func getOpenAIApiKey() -> String {
        return remoteConfig.configValue(forKey: "openai_api_key").stringValue ?? ""
    }

    // MARK: - Firestore - Reservations

    /// 예약 저장 또는 업데이트
    /// - 신규: 새 문서 생성
    /// - 수정: 기존 문서 업데이트
    func saveReservation(_ reservation: Reservation) async throws -> String {
        var reservationData = reservation

        // Generate ID if not exists (신규 예약)
        if reservationData.id == nil {
            reservationData.id = UUID().uuidString
        }

        // Add device ID for tracking
        reservationData.deviceId = DeviceManager.shared.deviceId

        // 기존 예약이 있는지 확인
        let existingDoc = try await findReservationDocument(byId: reservationData.id!)

        if let existingDoc = existingDoc {
            // 기존 예약 수정 - 문서 업데이트
            print("📝 기존 예약 수정: \(existingDoc.documentID)")
            try existingDoc.reference.setData(from: reservationData, merge: false) // 전체 덮어쓰기
            return reservationData.id!
        } else {
            // 신규 예약 - 새 문서 생성
            let timestamp = Int(Date().timeIntervalSince1970)
            let deviceIdSuffix = String(reservationData.deviceId?.prefix(8) ?? "unknown")
            let sanitizedName = reservationData.patientName
                .replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "/", with: "_")
            let documentName = "\(sanitizedName)_\(timestamp)_\(deviceIdSuffix)"

            print("✨ 신규 예약 생성: \(documentName)")
            let docRef = db.collection("reservations").document(documentName)
            try docRef.setData(from: reservationData)
            return reservationData.id!
        }
    }

    /// 예약 ID로 Firestore 문서 찾기
    private func findReservationDocument(byId id: String) async throws -> QueryDocumentSnapshot? {
        let snapshot = try await db.collection("reservations")
            .whereField("id", isEqualTo: id)
            .limit(to: 1)
            .getDocuments()

        return snapshot.documents.first
    }

    /// 예약 정보 업데이트 (전체 필드)
    /// - saveReservation과 동일하지만 명시적으로 업데이트 의도를 나타냄
    func updateReservation(_ reservation: Reservation) async throws -> String {
        guard let reservationId = reservation.id else {
            throw NSError(domain: "FirebaseManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Reservation ID is required for update"])
        }

        print("🔄 예약 업데이트: \(reservationId)")
        return try await saveReservation(reservation)
    }

    func getReservations() async throws -> [Reservation] {
        // Get only reservations from this device
        let deviceId = DeviceManager.shared.deviceId
        let snapshot = try await db.collection("reservations")
            .whereField("deviceId", isEqualTo: deviceId)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Reservation.self)
        }
    }

    func getReservationStatus(id: String) async throws -> ReservationStatus? {
        // Query to find reservation by ID
        let snapshot = try await db.collection("reservations")
            .whereField("id", isEqualTo: id)
            .limit(to: 1)
            .getDocuments()

        guard let doc = snapshot.documents.first,
              let reservation = try? doc.data(as: Reservation.self) else {
            return nil
        }

        return reservation.status
    }

    func updateReservationStatus(id: String, status: ReservationStatus) async throws {
        // Find document by reservation ID field
        let snapshot = try await db.collection("reservations")
            .whereField("id", isEqualTo: id)
            .limit(to: 1)
            .getDocuments()

        guard let document = snapshot.documents.first else {
            throw NSError(domain: "FirebaseManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Reservation not found"])
        }

        // Update the document
        try await document.reference.updateData(["status": status.rawValue])
    }

    func deleteReservation(id: String) async throws {
        // Find document by reservation ID field
        let snapshot = try await db.collection("reservations")
            .whereField("id", isEqualTo: id)
            .limit(to: 1)
            .getDocuments()

        guard let document = snapshot.documents.first else {
            throw NSError(domain: "FirebaseManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Reservation not found"])
        }

        // Delete the document
        try await document.reference.delete()
    }

    /// 예약 취소 - Firebase 문서 삭제
    func cancelReservation(id: String) async throws {
        print("🗑️ 예약 취소 및 삭제: \(id)")
        try await deleteReservation(id: id)
    }

    // MARK: - Storage - File Upload
    func uploadFile(data: Data, fileName: String, userName: String) async throws -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let path = "reservations/\(userName)_\(timestamp)/\(fileName)"
        let storageRef = storage.reference().child(path)

        let metadata = StorageMetadata()
        metadata.contentType = getContentType(for: fileName)

        _ = try await storageRef.putDataAsync(data, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }

    func uploadFiles(files: [(data: Data, name: String)], userName: String) async throws -> [String] {
        var urls: [String] = []

        for (index, file) in files.enumerated() {
            let fileName = "\(index)_\(file.name)"
            let url = try await uploadFile(data: file.data, fileName: fileName, userName: userName)
            urls.append(url)
        }

        return urls
    }

    private func getContentType(for fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "pdf":
            return "application/pdf"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        default:
            return "application/octet-stream"
        }
    }
}
