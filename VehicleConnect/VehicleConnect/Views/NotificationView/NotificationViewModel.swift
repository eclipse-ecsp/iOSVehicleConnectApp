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

class NotificationViewModel: ObservableObject {

    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var vehicleAlerts: VehicleAlerts?
    let service: NotificationServiceable
    init(service: NotificationServiceable) {
        self.service = service
    }
}

extension NotificationViewModel {

    /// Get Notification Alerts Service call
    /// - Parameter completion: completion block returns true or false
    func getNotifications(_ completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let vehicleId = Helper.getSelectedVehicleId()
            let startDate: Date? = Date().beforeSevenDay()
            let till = String(Date().millisecondsSince1970)
            let from = String(startDate!.millisecondsSince1970)
            let data = QueryData(from: from, till: till, alertType: nType, readStatus: tAll, page: kPage, size: kSize)
            let request = NotificationRequest(vehicleId: vehicleId, query: data)
            let result = await service.getAlerts(request)
            switch result {
            case .success(let response):
                vehicleAlerts = response.model
                completion(true)
            case .failure(let error):
                switch error {
                case .environmentNotConfigured, .notRechable:
                    showingAlert = true
                    alertMessage = error.message
                default:
                    showingAlert = false
                }
                completion(false)
            }
        }
    }

    /// Share device token  to server to get the push notifications
    /// - Parameter completion: completion block returns true or false
    func shareDeviceToken(_ completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let vehicleId = Helper.getSelectedVehicleId()
            let userId = Helper.getUserEmail()
            let token = Helper.getSDeviceToken()
            let channel = Channel(appPlatform: "iOS", type: "push", enabled: true,
                                  deviceTokens: [token], service: "apns")
            let data = ChannelData(group: "all", channels: [channel], enabled: true)
            let request = DeviceTokenRequest(vehicleId: vehicleId, userId: userId, postData: [data])
            let result = await service.shareDeviceToken(request)
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                switch error {
                case .environmentNotConfigured, .notRechable:
                    showingAlert = true
                    alertMessage = error.message
                default:
                    showingAlert = false
                }
                completion(false)
            }
        }
    }
}
