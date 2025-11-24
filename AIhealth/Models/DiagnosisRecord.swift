//
//  DiagnosisRecord.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation

struct DiagnosisRecord: Identifiable, Codable {
    let id: String
    let date: Date
    let summary: String
    let symptoms: String
    let recommendations: String

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        summary: String,
        symptoms: String,
        recommendations: String
    ) {
        self.id = id
        self.date = date
        self.summary = summary
        self.symptoms = symptoms
        self.recommendations = recommendations
    }
}
