//
//  ReservationScreen.swift
//  AIhealth
//
//  Created on 2025-10-28.
//

import SwiftUI
import PhotosUI

struct ReservationScreen: View {
    @StateObject private var viewModel = ReservationViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    var reportSummary: String? = nil

    enum Field: Hashable {
        case patientName
        case patientIdNumber
        case patientAddress
        case patientPhone
        case dateOfBirth
        case passportNumber
        case passportExpiryDate
        case email
    }

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: AppTheme.spacingLarge) {
                        // Patient Info Section
                        patientInfoSection
                            .id("patientInfo")

                        // Hospital Type Selection
                        hospitalTypeSection
                            .id("hospitalType")

                        // Conditional sections based on hospital type
                        if viewModel.reservation.hospitalType == .private_ {
                            // 개인병원 flow
                            privateHospitalSection
                                .id("hospitalDetails")
                        } else {
                            // 상급병원 flow
                            majorHospitalSection
                                .id("hospitalDetails")
                        }

                        // Symptoms Section (common)
                        symptomsSection
                            .id("symptoms")

                        // Notes Section (common)
                        notesSection
                            .id("notes")

                        // Attachment Section (common)
                        attachmentSection
                            .id("attachments")

                        // Report Summary (if available)
                        if let summary = reportSummary {
                            reportSummarySection(summary: summary)
                                .id("summary")
                        }

                        // Submit Button
                        submitButton
                            .id("submit")
                    }
                    .padding()
                }
                .background(Color.backgroundPrimary)
                .onTapGesture {
                    // 빈 공간 터치 시 키보드 내리기
                    focusedField = nil
                }
                .onChange(of: viewModel.reservation.hospitalType) { _ in
                    withAnimation {
                        proxy.scrollTo("hospitalDetails", anchor: .top)
                    }
                }
                .onChange(of: viewModel.selectedProvince) { newValue in
                    if !newValue.isEmpty {
                        focusedField = nil
                        // 시/도 선택 후 약간의 딜레이를 주고 구/군 선택 부분으로 스크롤
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if let districts = viewModel.districts[newValue], !districts.isEmpty {
                                // 구/군이 있으면 스크롤은 하지 않음 (바로 아래에 있음)
                            }
                        }
                    }
                }
                .onChange(of: viewModel.selectedDistrict) { newValue in
                    if !newValue.isEmpty {
                        focusedField = nil
                        // 구/군 선택 완료 후 날짜 선택으로 부드럽게 스크롤
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                proxy.scrollTo("hospitalDetails", anchor: .center)
                            }
                        }
                    }
                }
                .onChange(of: viewModel.reservation.preferredTime) { newValue in
                    if newValue != nil {
                        focusedField = nil
                        // 개인병원 플로우: 시간 선택 후 의료과 선택이 남아있으면 그쪽으로, 아니면 증상으로
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if viewModel.reservation.hospitalType == .private_ {
                                // 개인병원: 의료과 선택 부분으로 스크롤 (선택은 옵션)
                                withAnimation {
                                    proxy.scrollTo("hospitalDetails", anchor: .bottom)
                                }
                            } else {
                                // 상급병원: 바로 증상으로 (이미 의료과 선택함)
                                withAnimation {
                                    proxy.scrollTo("symptoms", anchor: .top)
                                }
                            }
                        }
                    }
                }
                .onChange(of: viewModel.reservation.selectedHospital) { newValue in
                    if !newValue.isEmpty {
                        focusedField = nil
                        // 병원 선택 완료 후 진료과 선택으로 부드럽게 스크롤
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                proxy.scrollTo("hospitalDetails", anchor: .center)
                            }
                        }
                    }
                }
                .onChange(of: viewModel.reservation.medicalDepartment) { newValue in
                    if newValue != nil {
                        focusedField = nil
                        // 진료과 선택 완료
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if viewModel.reservation.hospitalType == .private_ {
                                // 개인병원: 의료과 선택 후 증상 입력으로
                                withAnimation {
                                    proxy.scrollTo("symptoms", anchor: .top)
                                }
                            } else {
                                // 상급병원: 날짜 선택으로 (의료과 → 날짜 → 시간 순서)
                                withAnimation {
                                    proxy.scrollTo("hospitalDetails", anchor: .center)
                                }
                            }
                        }
                    }
                }
                .onChange(of: viewModel.reservation.preferredDate) { newValue in
                    if newValue != nil {
                        focusedField = nil
                        // 날짜 선택 완료 후 시간 선택으로 부드럽게 스크롤
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                proxy.scrollTo("hospitalDetails", anchor: .center)
                            }
                        }
                    }
                }
            }

            if viewModel.isLoading {
                LoadingOverlay(message: "submitting_reservation".localized)
            }
        }
        .navigationTitle("reservation_title".localized)
        .navigationBarTitleDisplayMode(.inline)
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
        .onAppear {
            if let summary = reportSummary {
                viewModel.reservation.reportSummary = summary
            }
        }
        .sheet(isPresented: $viewModel.showDatePicker) {
            datePickerSheet
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(selectedImage: $viewModel.pickerImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $viewModel.showCamera) {
            ImagePicker(selectedImage: $viewModel.pickerImage, sourceType: .camera)
        }
        .onChange(of: viewModel.pickerImage) { image in
            if let image = image {
                viewModel.addImage(image)
                viewModel.pickerImage = nil
            }
        }
    }

    // MARK: - Patient Info Section
    private var patientInfoSection: some View {
        let isKorean = Locale.current.language.languageCode?.identifier == "ko"

        return CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("patient_info".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                // Name (common for both)
                CommonTextField(
                    placeholder: "name_placeholder".localized,
                    text: $viewModel.reservation.patientName,
                    leadingIcon: "person.fill",
                    returnKeyType: .next,
                    onSubmit: {
                        focusedField = isKorean ? .patientIdNumber : .dateOfBirth
                    }
                )
                .focused($focusedField, equals: .patientName)

                if isKorean {
                    // Korean version: ID Number, Address, Phone
                    CommonTextField(
                        placeholder: "id_number_placeholder".localized,
                        text: $viewModel.reservation.patientIdNumber,
                        leadingIcon: "number",
                        returnKeyType: .next,
                        onSubmit: {
                            focusedField = .patientAddress
                        }
                    )
                    .focused($focusedField, equals: .patientIdNumber)

                    CommonTextField(
                        placeholder: "address_placeholder".localized,
                        text: $viewModel.reservation.patientAddress,
                        leadingIcon: "house.fill",
                        returnKeyType: .next,
                        onSubmit: {
                            focusedField = .patientPhone
                        }
                    )
                    .focused($focusedField, equals: .patientAddress)

                    CommonTextField(
                        placeholder: "phone_placeholder".localized,
                        text: $viewModel.reservation.patientPhone,
                        keyboardType: .phonePad,
                        leadingIcon: "phone.fill",
                        returnKeyType: .done,
                        onSubmit: {
                            focusedField = nil
                        }
                    )
                    .focused($focusedField, equals: .patientPhone)
                } else {
                    // English version: Date of Birth, Contact Number, Address in Korea, Passport Number, Passport Expiry, Email
                    CommonTextField(
                        placeholder: "date_of_birth_placeholder".localized,
                        text: $viewModel.reservation.dateOfBirth,
                        leadingIcon: "calendar",
                        returnKeyType: .next,
                        onSubmit: {
                            focusedField = .patientPhone
                        }
                    )
                    .focused($focusedField, equals: .dateOfBirth)

                    CommonTextField(
                        placeholder: "contact_number_placeholder".localized,
                        text: $viewModel.reservation.patientPhone,
                        keyboardType: .phonePad,
                        leadingIcon: "phone.fill",
                        returnKeyType: .next,
                        onSubmit: {
                            focusedField = .patientAddress
                        }
                    )
                    .focused($focusedField, equals: .patientPhone)

                    CommonTextField(
                        placeholder: "address_in_korea_placeholder".localized,
                        text: $viewModel.reservation.patientAddress,
                        leadingIcon: "house.fill",
                        returnKeyType: .next,
                        onSubmit: {
                            focusedField = .passportNumber
                        }
                    )
                    .focused($focusedField, equals: .patientAddress)

                    CommonTextField(
                        placeholder: "passport_number_placeholder".localized,
                        text: $viewModel.reservation.passportNumber,
                        leadingIcon: "doc.text.fill",
                        returnKeyType: .next,
                        onSubmit: {
                            focusedField = .passportExpiryDate
                        }
                    )
                    .focused($focusedField, equals: .passportNumber)

                    CommonTextField(
                        placeholder: "passport_expiry_placeholder".localized,
                        text: $viewModel.reservation.passportExpiryDate,
                        leadingIcon: "calendar.badge.clock",
                        returnKeyType: .next,
                        onSubmit: {
                            focusedField = .email
                        }
                    )
                    .focused($focusedField, equals: .passportExpiryDate)

                    CommonTextField(
                        placeholder: "email_placeholder".localized,
                        text: $viewModel.reservation.email,
                        keyboardType: .emailAddress,
                        leadingIcon: "envelope.fill",
                        returnKeyType: .done,
                        onSubmit: {
                            focusedField = nil
                        }
                    )
                    .focused($focusedField, equals: .email)
                }
            }
        }
    }

    // MARK: - Hospital Type Section
    private var hospitalTypeSection: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("hospital_type".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                Picker("hospital_type".localized, selection: $viewModel.reservation.hospitalType) {
                    ForEach(HospitalType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }

    // MARK: - Private Hospital Section (개인병원)
    private var privateHospitalSection: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("region_info".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                // Region Selection - Province
                VStack(alignment: .leading, spacing: 8) {
                    Text("select_province".localized)
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                        .foregroundColor(.textSecondary)

                    Menu {
                        ForEach(viewModel.provinces, id: \.self) { province in
                            Button(province.localized) {
                                viewModel.selectedProvince = province
                                viewModel.selectedDistrict = ""
                                viewModel.reservation.preferredRegion = province
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "map.fill")
                                .foregroundColor(.bluePrimary)
                            Text(viewModel.selectedProvince.isEmpty ? "select_province_prompt".localized : viewModel.selectedProvince.localized)
                                .foregroundColor(viewModel.selectedProvince.isEmpty ? .textSecondary : .textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textSecondary)
                        }
                        .font(.system(size: AppTheme.fontSizeMedium))
                        .padding()
                        .background(Color.backgroundSecondary)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(Color.textTertiary, lineWidth: 1)
                        )
                    }
                }

                // Region Selection - District
                if !viewModel.selectedProvince.isEmpty,
                   let districts = viewModel.districts[viewModel.selectedProvince] {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("region_district_label".localized)
                            .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                            .foregroundColor(.textSecondary)

                        Menu {
                            ForEach(districts, id: \.self) { district in
                                Button(district.localized) {
                                    viewModel.selectedDistrict = district
                                    viewModel.reservation.preferredRegion = "\(viewModel.selectedProvince) \(district)"
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.bluePrimary)
                                Text(viewModel.selectedDistrict.isEmpty ? "select_district_prompt".localized : viewModel.selectedDistrict.localized)
                                    .foregroundColor(viewModel.selectedDistrict.isEmpty ? .textSecondary : .textPrimary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.textSecondary)
                            }
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .padding()
                            .background(Color.backgroundSecondary)
                            .cornerRadius(AppTheme.cornerRadiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                    .stroke(Color.textTertiary, lineWidth: 1)
                            )
                        }
                    }
                }

                // Date Selection (Korean Calendar)
                VStack(alignment: .leading, spacing: 8) {
                    Text("preferred_date_label".localized)
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                        .foregroundColor(.textSecondary)

                    Button(action: {
                        viewModel.showDatePicker = true
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.bluePrimary)
                            Text(viewModel.reservation.preferredDate == nil ? "select_date".localized : viewModel.formattedDateForDisplay)
                                .foregroundColor(viewModel.reservation.preferredDate == nil ? .textSecondary : .textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textSecondary)
                        }
                        .font(.system(size: AppTheme.fontSizeMedium))
                        .padding()
                        .background(Color.backgroundSecondary)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(Color.textTertiary, lineWidth: 1)
                        )
                    }
                }

                // Time Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("preferred_time_label".localized)
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                        .foregroundColor(.textSecondary)

                    Menu {
                        ForEach(viewModel.availableTimes, id: \.self) { time in
                            Button(time) {
                                viewModel.reservation.preferredTime = time
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.mintAccent)
                            Text(viewModel.reservation.preferredTime ?? "select_time".localized)
                                .foregroundColor(viewModel.reservation.preferredTime == nil ? .textSecondary : .textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textSecondary)
                        }
                        .font(.system(size: AppTheme.fontSizeMedium))
                        .padding()
                        .background(Color.backgroundSecondary)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(Color.textTertiary, lineWidth: 1)
                        )
                    }
                }

                // Medical Department (개인병원도 진료과 선택 가능)
                VStack(alignment: .leading, spacing: 8) {
                    Text("department_optional".localized)
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                        .foregroundColor(.textSecondary)

                    Menu {
                        ForEach(MedicalDepartment.allCases, id: \.self) { dept in
                            Button(dept.displayName) {
                                viewModel.reservation.medicalDepartment = dept.rawValue
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "cross.case.fill")
                                .foregroundColor(.bluePrimary)
                            Text(viewModel.reservation.medicalDepartment?.localized ?? "not_selected".localized)
                                .foregroundColor(viewModel.reservation.medicalDepartment == nil ? .textSecondary : .textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textSecondary)
                        }
                        .font(.system(size: AppTheme.fontSizeMedium))
                        .padding()
                        .background(Color.backgroundSecondary)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(Color.textTertiary, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Major Hospital Section (상급병원)
    private var majorHospitalSection: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("hospital_and_treatment_info".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                // Hospital Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("hospital_selection".localized)
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                        .foregroundColor(.textSecondary)

                    Menu {
                        ForEach(MajorHospital.allCases, id: \.self) { hospital in
                            Button(hospital.displayName.localized) {
                                viewModel.reservation.selectedHospital = hospital.displayName
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.bluePrimary)
                            Text(viewModel.reservation.selectedHospital.isEmpty ? "select_hospital".localized : viewModel.reservation.selectedHospital.localized)
                                .foregroundColor(viewModel.reservation.selectedHospital.isEmpty ? .textSecondary : .textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textSecondary)
                        }
                        .font(.system(size: AppTheme.fontSizeMedium))
                        .padding()
                        .background(Color.backgroundSecondary)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(Color.textTertiary, lineWidth: 1)
                        )
                    }
                }

                // Medical Department (Optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("department_optional".localized)
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                        .foregroundColor(.textSecondary)

                    Menu {
                        ForEach(MedicalDepartment.allCases, id: \.self) { dept in
                            Button(dept.displayName) {
                                viewModel.reservation.medicalDepartment = dept.rawValue
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "cross.case.fill")
                                .foregroundColor(.mintAccent)
                            Text(viewModel.reservation.medicalDepartment?.localized ?? "not_selected".localized)
                                .foregroundColor(viewModel.reservation.medicalDepartment == nil ? .textSecondary : .textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textSecondary)
                        }
                        .font(.system(size: AppTheme.fontSizeMedium))
                        .padding()
                        .background(Color.backgroundSecondary)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(Color.textTertiary, lineWidth: 1)
                        )
                    }
                }

                // Preferred Doctor (Optional)
                CommonTextField(
                    placeholder: "preferred_doctor_optional".localized,
                    text: Binding(
                        get: { viewModel.reservation.doctorName ?? "" },
                        set: { viewModel.reservation.doctorName = $0.isEmpty ? nil : $0 }
                    ),
                    leadingIcon: "person.crop.circle"
                )

                // Date Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("preferred_date_label".localized)
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                        .foregroundColor(.textSecondary)

                    Button(action: {
                        viewModel.showDatePicker = true
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.bluePrimary)
                            Text(viewModel.reservation.preferredDate == nil ? "select_date".localized : viewModel.formattedDateForDisplay)
                                .foregroundColor(viewModel.reservation.preferredDate == nil ? .textSecondary : .textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textSecondary)
                        }
                        .font(.system(size: AppTheme.fontSizeMedium))
                        .padding()
                        .background(Color.backgroundSecondary)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(Color.textTertiary, lineWidth: 1)
                        )
                    }
                }

                // Time Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("preferred_time_label".localized)
                        .font(.system(size: AppTheme.fontSizeMedium, weight: .medium))
                        .foregroundColor(.textSecondary)

                    Menu {
                        ForEach(viewModel.availableTimes, id: \.self) { time in
                            Button(time) {
                                viewModel.reservation.preferredTime = time
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.mintAccent)
                            Text(viewModel.reservation.preferredTime ?? "select_time".localized)
                                .foregroundColor(viewModel.reservation.preferredTime == nil ? .textSecondary : .textPrimary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.textSecondary)
                        }
                        .font(.system(size: AppTheme.fontSizeMedium))
                        .padding()
                        .background(Color.backgroundSecondary)
                        .cornerRadius(AppTheme.cornerRadiusMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium)
                                .stroke(Color.textTertiary, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Symptoms Section
    private var symptomsSection: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("main_symptoms".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                CommonTextEditor(
                    placeholder: "symptoms_placeholder".localized,
                    text: $viewModel.reservation.symptoms,
                    height: 120
                )
            }
        }
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("additional_notes".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                CommonTextEditor(
                    placeholder: "notes_placeholder".localized,
                    text: Binding(
                        get: { viewModel.reservation.notes ?? "" },
                        set: { viewModel.reservation.notes = $0.isEmpty ? nil : $0 }
                    ),
                    height: 80
                )
            }
        }
    }

    // MARK: - Attachment Section
    private var attachmentSection: some View {
        CommonCard {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                Text("attached_files".localized)
                    .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                    .foregroundColor(.textPrimary)

                HStack(spacing: AppTheme.spacingSmall) {
                    Button(action: {
                        viewModel.showImagePicker = true
                    }) {
                        Label("photo_library".localized, systemImage: "photo")
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .padding()
                            .background(Color.blueLight)
                            .foregroundColor(.bluePrimary)
                            .cornerRadius(AppTheme.cornerRadiusSmall)
                    }

                    Button(action: {
                        viewModel.showCamera = true
                    }) {
                        Label("camera".localized, systemImage: "camera")
                            .font(.system(size: AppTheme.fontSizeMedium))
                            .padding()
                            .background(Color.mintLight)
                            .foregroundColor(.mintAccent)
                            .cornerRadius(AppTheme.cornerRadiusSmall)
                    }
                }

                // Display selected images
                if !viewModel.selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppTheme.spacingSmall) {
                            ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(AppTheme.cornerRadiusSmall)
                                        .clipped()

                                    Button(action: {
                                        viewModel.removeImage(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.errorColor)
                                            .background(Color.white.clipShape(Circle()))
                                    }
                                    .offset(x: 5, y: -5)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Report Summary Section
    private func reportSummarySection(summary: String) -> some View {
        CommonCard(useGradient: true) {
            VStack(alignment: .leading, spacing: AppTheme.spacingMedium) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.bluePrimary)
                    Text("ai_summary".localized)
                        .font(.system(size: AppTheme.fontSizeXLarge, weight: .semibold))
                        .foregroundColor(.textPrimary)
                }

                Text(summary.prefix(150) + "...")
                    .font(.system(size: AppTheme.fontSizeMedium))
                    .foregroundColor(.textSecondary)
                    .lineLimit(3)
            }
        }
    }

    // MARK: - Submit Button
    private var submitButton: some View {
        CommonButton(
            title: "submit_reservation".localized,
            variant: .primary,
            action: {
                viewModel.submitReservation()
            },
            isLoading: viewModel.isLoading,
            isEnabled: !viewModel.isLoading
        )
    }

    // MARK: - Date Picker Sheet
    private var datePickerSheet: some View {
        NavigationView {
            VStack(spacing: AppTheme.spacingLarge) {
                DatePicker(
                    "select_date".localized,
                    selection: $viewModel.selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale.current)
                .environment(\.calendar, Calendar.current)
                .padding()

                // Selected Date Display
                Text(viewModel.formattedDateForDisplay)
                    .font(.system(size: AppTheme.fontSizeLarge, weight: .semibold))
                    .foregroundColor(.bluePrimary)
                    .padding()

                Spacer()

                // Confirm Button
                CommonButton(
                    title: "done".localized,
                    variant: .primary,
                    action: {
                        viewModel.reservation.preferredDate = viewModel.formattedDateForStorage
                        viewModel.showDatePicker = false
                    }
                )
                .padding()
            }
            .navigationTitle("select_date".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        viewModel.showDatePicker = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReservationScreen()
    }
}
