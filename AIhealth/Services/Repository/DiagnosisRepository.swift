//
//  DiagnosisRepository.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation

class DiagnosisRepository {
    private let fileManager = FileManager.default

    // Use Documents directory - persists across app launches
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var recordsFileURL: URL {
        documentsDirectory.appendingPathComponent("diagnosis_records.json")
    }

    func saveDiagnosisRecord(_ record: DiagnosisRecord) throws {
        var records = getAllDiagnosisRecords()

        // Update existing or add new
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
        } else {
            records.append(record)
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(records)
        try data.write(to: recordsFileURL, options: .atomic)
    }

    func getAllDiagnosisRecords() -> [DiagnosisRecord] {
        guard fileManager.fileExists(atPath: recordsFileURL.path),
              let data = try? Data(contentsOf: recordsFileURL) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let records = (try? decoder.decode([DiagnosisRecord].self, from: data)) ?? []
        return records.sorted { $0.date > $1.date }
    }

    func getDiagnosisRecord(id: String) -> DiagnosisRecord? {
        return getAllDiagnosisRecords().first { $0.id == id }
    }

    func deleteDiagnosisRecord(id: String) throws {
        var records = getAllDiagnosisRecords()
        records.removeAll { $0.id == id }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(records)
        try data.write(to: recordsFileURL, options: .atomic)
    }

    func clearAllDiagnosisRecords() {
        try? fileManager.removeItem(at: recordsFileURL)
    }
}
