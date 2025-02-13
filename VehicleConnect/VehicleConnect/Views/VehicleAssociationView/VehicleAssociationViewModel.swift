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

/// Device association view model
class VehicleAssociationViewModel: ObservableObject {

    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var deviceDetail: ImeiVerification?

    let service: VehicleServiceable
    init(service: VehicleServiceable) {
        self.service = service
    }
}

extension VehicleAssociationViewModel {

    /// Service  call to add or associate device to user
    /// - Parameters:
    ///   - imei: accept Imei as input
    ///   - completion: block  retuns true or false on completion
    func addDevice(_ imei: String, _ completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let request = AssociateRequest(imei: imei)
            let result = await service.addDevice(request)
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                alertMessage = error.message
                showingAlert = true
                completion(false)
            }
        }
    }
    /// Service  call to remove or terminate device
    /// - Parameters:
    ///   - imei: accept Imei as input
    ///   - completion: block  retuns  success true or false  on completion
    func removeDevice(_ imei: String, _ completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let request = TerminateRequest(imei: imei)
            let result = await service.removeDevice(request)
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                showingAlert = true
                alertMessage = error.message
                completion(false)
            }
        }
    }

    /// Service  call to validate device imei
    /// - Parameters:
    ///   - imei: accept Imei as input
    ///   - completion: block  retuns  success true or false  on completion
    func validateIMEI(_ imei: String, _ completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            if imei.isEmpty {
                showingAlert = true
                alertMessage = kEnterValidIMEI
                return
            }
            let request = ValidateImeiRequest(imei: imei)
            let result = await service.validateIMEI(request)
            switch result {
            case .success((let resopnse)):
                self.deviceDetail = resopnse.model[0]
                completion(true)
            case .failure(let error):
                alertMessage = error.message
                showingAlert = true
                completion(false)
            }
        }
    }
}
