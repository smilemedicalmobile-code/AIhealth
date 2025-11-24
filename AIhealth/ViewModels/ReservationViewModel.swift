//
//  ReservationViewModel.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine

@MainActor
class ReservationViewModel: ObservableObject {
    @Published var reservation = Reservation()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    @Published var selectedImages: [UIImage] = []
    @Published var selectedFiles: [(data: Data, name: String)] = []

    private let reservationRepository = ReservationRepository()
    private var isEditMode = false

    // 수정 모드 생성자
    convenience init(editingReservation: Reservation) {
        self.init()
        self.reservation = editingReservation
        self.isEditMode = true
    }

    // UI State
    @Published var showImagePicker = false
    @Published var showFilePicker = false
    @Published var showCamera = false
    @Published var showDatePicker = false

    // Date picker state for private hospital
    @Published var selectedDate = Date()

    // Computed property for formatted date display
    var formattedDateForDisplay: String {
        let formatter = DateFormatter()
        let currentLocale = Locale.current.language.languageCode?.identifier ?? "ko"

        switch currentLocale {
        case "en":
            formatter.dateFormat = "MMM d, yyyy (E)"
            formatter.locale = Locale(identifier: "en_US")
        case "ja":
            formatter.dateFormat = "yyyy年M月d日 (E)"
            formatter.locale = Locale(identifier: "ja_JP")
        default: // Korean
            formatter.dateFormat = "yyyy년 M월 d일 (E)"
            formatter.locale = Locale(identifier: "ko_KR")
        }

        return formatter.string(from: selectedDate)
    }

    // Computed property for Firebase storage format
    var formattedDateForStorage: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Use POSIX for consistent storage format
        return formatter.string(from: selectedDate)
    }

    // Region selection state
    @Published var selectedProvince: String = ""
    @Published var selectedDistrict: String = ""

    // Temporary image holder for picker
    @Published var pickerImage: UIImage?

    // Available options for private hospital
    let provinces = [
        "서울특별시", "부산광역시", "대구광역시", "인천광역시",
        "광주광역시", "대전광역시", "울산광역시", "세종특별자치시",
        "경기도", "강원특별자치도", "충청북도", "충청남도",
        "전북특별자치도", "전라남도", "경상북도", "경상남도", "제주특별자치도"
    ]

    let districts: [String: [String]] = [
        "서울특별시": ["강남구", "강동구", "강북구", "강서구", "관악구", "광진구", "구로구", "금천구", "노원구", "도봉구", "동대문구", "동작구", "마포구", "서대문구", "서초구", "성동구", "성북구", "송파구", "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"],
        "부산광역시": ["강서구", "금정구", "기장군", "남구", "동구", "동래구", "부산진구", "북구", "사상구", "사하구", "서구", "수영구", "연제구", "영도구", "중구", "해운대구"],
        "대구광역시": ["남구", "달서구", "달성군", "동구", "북구", "서구", "수성구", "중구"],
        "인천광역시": ["강화군", "계양구", "남동구", "동구", "미추홀구", "부평구", "서구", "연수구", "옹진군", "중구"],
        "광주광역시": ["광산구", "남구", "동구", "북구", "서구"],
        "대전광역시": ["대덕구", "동구", "서구", "유성구", "중구"],
        "울산광역시": ["남구", "동구", "북구", "울주군", "중구"],
        "세종특별자치시": ["세종시"],
        "경기도": ["가평군", "고양시", "과천시", "광명시", "광주시", "구리시", "군포시", "김포시", "남양주시", "동두천시", "부천시", "성남시", "수원시", "시흥시", "안산시", "안성시", "안양시", "양주시", "양평군", "여주시", "연천군", "오산시", "용인시", "의왕시", "의정부시", "이천시", "파주시", "평택시", "포천시", "하남시", "화성시"],
        "강원특별자치도": ["강릉시", "고성군", "동해시", "삼척시", "속초시", "양구군", "양양군", "영월군", "원주시", "인제군", "정선군", "철원군", "춘천시", "태백시", "평창군", "홍천군", "화천군", "횡성군"],
        "충청북도": ["괴산군", "단양군", "보은군", "영동군", "옥천군", "음성군", "제천시", "증평군", "진천군", "청주시", "충주시"],
        "충청남도": ["계룡시", "공주시", "금산군", "논산시", "당진시", "보령시", "부여군", "서산시", "서천군", "아산시", "예산군", "천안시", "청양군", "태안군", "홍성군"],
        "전북특별자치도": ["고창군", "군산시", "김제시", "남원시", "무주군", "부안군", "순창군", "완주군", "익산시", "임실군", "장수군", "전주시", "정읍시", "진안군"],
        "전라남도": ["강진군", "고흥군", "곡성군", "광양시", "구례군", "나주시", "담양군", "목포시", "무안군", "보성군", "순천시", "신안군", "여수시", "영광군", "영암군", "완도군", "장성군", "장흥군", "진도군", "함평군", "해남군", "화순군"],
        "경상북도": ["경산시", "경주시", "고령군", "구미시", "군위군", "김천시", "문경시", "봉화군", "상주시", "성주군", "안동시", "영덕군", "영양군", "영주시", "영천시", "예천군", "울릉군", "울진군", "의성군", "청도군", "청송군", "칠곡군", "포항시"],
        "경상남도": ["거제시", "거창군", "고성군", "김해시", "남해군", "밀양시", "사천시", "산청군", "양산시", "의령군", "진주시", "창녕군", "창원시", "통영시", "하동군", "함안군", "함양군", "합천군"],
        "제주특별자치도": ["서귀포시", "제주시"]
    ]

    let availableTimes = [
        "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
        "12:00", "12:30", "13:00", "13:30", "14:00", "14:30",
        "15:00", "15:30", "16:00", "16:30", "17:00", "17:30",
        "18:00", "18:30", "19:00", "19:30", "20:00", "20:30",
        "21:00", "21:30", "22:00", "22:30", "23:00", "23:30", "24:00"
    ]

    func submitReservation() {
        Task {
            await submitReservationAsync()
        }
    }

    private func submitReservationAsync() async {
        guard validateReservation() else { return }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            // Upload files if any
            var uploadedUrls: [String] = []

            if !selectedImages.isEmpty || !selectedFiles.isEmpty {
                var allFiles: [(data: Data, name: String)] = []

                // Convert images to data
                for (index, image) in selectedImages.enumerated() {
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        allFiles.append((imageData, "image_\(index).jpg"))
                    }
                }

                // Add selected files
                allFiles.append(contentsOf: selectedFiles)

                uploadedUrls = try await reservationRepository.uploadFiles(
                    files: allFiles,
                    userName: reservation.patientName
                )
            }

            // Update reservation with uploaded URLs
            reservation.attachmentUrls = uploadedUrls

            // Save reservation
            let reservationId = try await reservationRepository.saveReservation(reservation)
            reservation.id = reservationId

            successMessage = "reservation_success".localized

            // Reset form after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.resetForm()
            }
        } catch {
            errorMessage = "reservation_error".localized + ": \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func validateReservation() -> Bool {
        let isKorean = Locale.current.language.languageCode?.identifier == "ko"

        // Common validation
        if reservation.patientName.isEmpty {
            errorMessage = "error_patient_name_required".localized
            return false
        }

        // Language-specific validation
        if isKorean {
            // Korean version: validate ID number, address, phone
            if reservation.patientIdNumber.isEmpty {
                errorMessage = "error_patient_id_required".localized
                return false
            }
            if reservation.patientAddress.isEmpty {
                errorMessage = "error_patient_address_required".localized
                return false
            }
            if reservation.patientPhone.isEmpty {
                errorMessage = "error_patient_phone_required".localized
                return false
            }
        } else {
            // English version: validate date of birth, passport, contact, address
            if reservation.dateOfBirth.isEmpty {
                errorMessage = "error_date_of_birth_required".localized
                return false
            }
            if reservation.passportNumber.isEmpty {
                errorMessage = "error_passport_number_required".localized
                return false
            }
            if reservation.passportExpiryDate.isEmpty {
                errorMessage = "error_passport_expiry_required".localized
                return false
            }
            if reservation.patientPhone.isEmpty {
                errorMessage = "error_contact_number_required".localized
                return false
            }
            if reservation.patientAddress.isEmpty {
                errorMessage = "error_address_in_korea_required".localized
                return false
            }
            // Email is optional, so no validation needed
        }

        // Symptoms validation (common)
        if reservation.symptoms.isEmpty {
            errorMessage = "error_symptoms_required".localized
            return false
        }

        // Hospital type specific validation
        if reservation.hospitalType == .private_ {
            // 개인병원 validation
            if reservation.preferredRegion.isEmpty {
                errorMessage = "error_region_required".localized
                return false
            }
            if reservation.preferredDate?.isEmpty ?? true {
                errorMessage = "error_date_required".localized
                return false
            }
            if reservation.preferredTime?.isEmpty ?? true {
                errorMessage = "error_time_required".localized
                return false
            }
        } else {
            // 상급병원 validation
            if reservation.selectedHospital.isEmpty {
                errorMessage = "error_hospital_required".localized
                return false
            }
            if reservation.preferredDate?.isEmpty ?? true {
                errorMessage = "error_date_required".localized
                return false
            }
            if reservation.preferredTime?.isEmpty ?? true {
                errorMessage = "error_time_required".localized
                return false
            }
        }

        return true
    }

    func addImage(_ image: UIImage) {
        selectedImages.append(image)
    }

    func removeImage(at index: Int) {
        selectedImages.remove(at: index)
    }

    func addFile(data: Data, name: String) {
        selectedFiles.append((data, name))
    }

    func removeFile(at index: Int) {
        selectedFiles.remove(at: index)
    }

    func resetForm() {
        reservation = Reservation()
        selectedImages.removeAll()
        selectedFiles.removeAll()
        errorMessage = nil
        successMessage = nil
    }

    // MARK: - Update Reservation
    func updateReservation() {
        Task {
            await updateReservationAsync()
        }
    }

    private func updateReservationAsync() async {
        isLoading = true
        errorMessage = nil

        do {
            guard let id = reservation.id else {
                errorMessage = "error_reservation_id_missing".localized
                isLoading = false
                return
            }

            // 수정된 예약 저장
            _ = try await reservationRepository.saveReservation(reservation)

            successMessage = "reservation_update_success".localized
        } catch {
            errorMessage = "reservation_update_error".localized + ": \(error.localizedDescription)"
        }

        isLoading = false
    }
}
