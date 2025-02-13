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

class VehicleProfileViewModel: ObservableObject {

    @Published var showingAlert = false
    @Published var alertMessage = ""
    let service: VehicleServiceable
    init(service: VehicleServiceable) {
        self.service = service
    }
}

extension VehicleProfileViewModel {

    ///  This is to update the vehicleproperties like vehicle name
    /// - Parameters:
    ///   - vehicleName: vehicle name to update
    ///   - vehicleId: vehicleId to update vehicle anme
    ///   - completion:  blck to return true or false
    func updateVehicleName(_ vehicleName: String, _ vehicleId: String, _ completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            /// Empty imei validation
            if vehicleName.isEmpty {
                showingAlert = true
                alertMessage = kEnterValidIMEI
                return
            }
            let vehicleAttibute = VehicleAttribute(name: vehicleName)
            let postParam = Attributes(vehicleAttributes: vehicleAttibute)
            let request = UpdateProfileRequest(vehicleId: vehicleId, params: postParam)
            let result = await service.updateVehicleProfile(request)
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

}
