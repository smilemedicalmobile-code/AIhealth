//
//  DeviceManager.swift
//  AIhealth
//
//  Created on 2025-10-30.
//

import Foundation

class DeviceManager {
    static let shared = DeviceManager()

    private let deviceIdKey = "com.aihealth.deviceId"

    private init() {}

    /// Returns a unique device identifier
    /// Creates one if it doesn't exist
    var deviceId: String {
        if let existingId = UserDefaults.standard.string(forKey: deviceIdKey) {
            return existingId
        }

        // Create new device ID
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: deviceIdKey)
        return newId
    }

    /// For debugging purposes
    func resetDeviceId() {
        UserDefaults.standard.removeObject(forKey: deviceIdKey)
    }
}
