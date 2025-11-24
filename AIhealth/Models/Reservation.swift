//
//  Reservation.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation

enum HospitalType: String, Codable, CaseIterable {
    case private_ = "개인병원"
    case majorHospital = "상급종합병원"

    var displayName: String {
        return self.rawValue.localized
    }

    // Support both old and new values during decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case "개인병원", "PRIVATE":
            self = .private_
        case "상급병원", "상급종합병원", "MAJOR_HOSPITAL":
            self = .majorHospital
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot initialize HospitalType from invalid String value \(rawValue)"
            )
        }
    }

    // Always encode as Korean
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

// Major hospitals list
enum MajorHospital: String, CaseIterable {
    case snuh = "서울대학교병원"
    case amc = "서울아산병원"
    case smc = "삼성서울병원"
    case severance = "세브란스병원"
    case cmcSeoul = "성모병원"

    var displayName: String {
        return self.rawValue
    }
}

enum ReservationStatus: String, Codable {
    case pending = "PENDING"
    case confirmed = "CONFIRMED"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"

    var displayName: String {
        switch self {
        case .pending: return "reservation_pending".localized
        case .confirmed: return "reservation_confirmed".localized
        case .completed: return "reservation_completed".localized
        case .cancelled: return "reservation_cancelled".localized
        }
    }
}

enum MedicalDepartment: String, Codable, CaseIterable {
    case none = "선택하지않음"
    case internalMedicine = "내과"
    case surgery = "외과"
    case orthopedics = "정형외과"
    case dermatology = "피부과"
    case ophthalmology = "안과"
    case otolaryngology = "이비인후과"
    case obstetrics = "산부인과"
    case pediatrics = "소아청소년과"
    case psychiatry = "정신건강의학과"
    case neurology = "신경과"
    case cardiology = "심장내과"
    case gastroenterology = "소화기내과"
    case pulmonology = "호흡기내과"
    case urology = "비뇨의학과"
    case familyMedicine = "가정의학과"

    var displayName: String {
        return self.rawValue.localized
    }
}

struct Reservation: Identifiable, Codable {
    var id: String?
    var deviceId: String? // Device identifier for tracking

    // Patient info (Korean)
    var patientName: String
    var patientIdNumber: String
    var patientAddress: String
    var patientPhone: String

    // Patient info (English/International)
    var dateOfBirth: String
    var passportNumber: String
    var passportExpiryDate: String
    var email: String

    // Hospital selection
    var hospitalType: HospitalType
    var preferredRegion: String
    var selectedHospital: String

    // Appointment details
    var symptoms: String
    var preferredDate: String?
    var preferredTime: String?
    var medicalDepartment: String?
    var doctorName: String?

    // Additional info
    var notes: String?
    var attachmentUrls: [String]
    var reportSummary: String?
    var createdAt: Date
    var status: ReservationStatus

    init(
        id: String? = nil,
        patientName: String = "",
        patientIdNumber: String = "",
        patientAddress: String = "",
        patientPhone: String = "",
        dateOfBirth: String = "",
        passportNumber: String = "",
        passportExpiryDate: String = "",
        email: String = "",
        hospitalType: HospitalType = .private_,
        preferredRegion: String = "",
        selectedHospital: String = "",
        symptoms: String = "",
        preferredDate: String? = nil,
        preferredTime: String? = nil,
        medicalDepartment: String? = nil,
        doctorName: String? = nil,
        notes: String? = nil,
        attachmentUrls: [String] = [],
        reportSummary: String? = nil,
        createdAt: Date = Date(),
        status: ReservationStatus = .pending
    ) {
        self.id = id
        self.patientName = patientName
        self.patientIdNumber = patientIdNumber
        self.patientAddress = patientAddress
        self.patientPhone = patientPhone
        self.dateOfBirth = dateOfBirth
        self.passportNumber = passportNumber
        self.passportExpiryDate = passportExpiryDate
        self.email = email
        self.hospitalType = hospitalType
        self.preferredRegion = preferredRegion
        self.selectedHospital = selectedHospital
        self.symptoms = symptoms
        self.preferredDate = preferredDate
        self.preferredTime = preferredTime
        self.medicalDepartment = medicalDepartment
        self.doctorName = doctorName
        self.notes = notes
        self.attachmentUrls = attachmentUrls
        self.reportSummary = reportSummary
        self.createdAt = createdAt
        self.status = status
    }
}
