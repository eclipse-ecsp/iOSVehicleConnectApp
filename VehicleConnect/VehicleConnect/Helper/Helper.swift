/********************************************************************************
 * Copyright (c) 2023-24 Harman International
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 ********************************************************************************/

import Foundation
import VehicleConnectSDK
let kUserDefault = UserDefaults.standard

struct Helper {
    static func setUserEmail(email: String) {
        kUserDefault.setValue(email, forKey: "UserEmail")
        kUserDefault.synchronize()
    }
    static func getUserEmail() -> String {
        return kUserDefault.string(forKey: "UserEmail") ?? ""
    }

    static func setSelectedVehicleName(name: String) {
        kUserDefault.setValue(name, forKey: "SelectedVehicle")
        kUserDefault.synchronize()
    }
    static func getSelectedVehicleName() -> String {
        return kUserDefault.string(forKey: "SelectedVehicle") ?? ""
    }

    static func setSelectedVehicleId(vehicleId: String) {
        kUserDefault.setValue(vehicleId, forKey: "vehicleId")
        kUserDefault.synchronize()
    }
    static func getSelectedVehicleId() -> String {
        return kUserDefault.string(forKey: "vehicleId") ?? ""
    }
    static func setSelectedVehicleProfile(vehicle: VehicleProfile) {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let data = try encoder.encode(vehicle)

            // Write/Set Data
            kUserDefault.setValue(data, forKey: "SelectedVehicleProfile")
            kUserDefault.synchronize()

        } catch {
            print("Unable to save selected vehicle profile(\(error))")
        }
    }

    static func getSelectedVehicleProfile() -> VehicleProfile? {
        if let data = UserDefaults.standard.data(forKey: "SelectedVehicleProfile") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let profile = try decoder.decode(VehicleProfile.self, from: data)
                return profile

            } catch {
                print("Unable to fetch selected vehicle profile (\(error))")
            }
        }
        return nil
    }
    static func setDeviceToken(token: String) {
        kUserDefault.setValue(token, forKey: "DeviceToken")
        kUserDefault.synchronize()
    }
    static func getDeviceToken() -> String {
        return kUserDefault.string(forKey: "DeviceToken") ?? ""
    }
    static func setIsDeviceTokenShared(isShared: Bool) {
        kUserDefault.setValue(isShared, forKey: "isTokenShared")
        kUserDefault.synchronize()
    }
    static func getIsDeviceTokenShared() -> Bool {
        return kUserDefault.bool(forKey: "isTokenShared")
    }

    static func setUserId(userId: String) {
        kUserDefault.setValue(userId, forKey: "UserId")
        kUserDefault.synchronize()
    }
    static func getUserId() -> String {
        return kUserDefault.string(forKey: "UserId") ?? ""
    }

    static func setSelectedDeviceId(id: String) {
        kUserDefault.setValue(id, forKey: "deviceId")
        kUserDefault.synchronize()
    }
    static func getSelectedDeviceId() -> String {
        return kUserDefault.string(forKey: "deviceId") ?? ""
    }

    static func removeAllData() {
        UserDefaults.standard.removeObject(forKey: "deviceId")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "DeviceToken")
        UserDefaults.standard.removeObject(forKey: "isTokenShared")
        UserDefaults.standard.removeObject(forKey: "SelectedVehicle")
        UserDefaults.standard.removeObject(forKey: "UserEmail")
        UserDefaults.standard.removeObject(forKey: "isTokenShared")
        UserDefaults.standard.removeObject(forKey: "SelectedVehicleProfile")

    }
}
