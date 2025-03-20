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

class HomeViewModel: ObservableObject {

    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var vehicles = [VehicleProfile]()
    @Published var vehicleNames = [String]()
    @Published var selectedVehicle: String = "My Car"
    let dispatchGroup = DispatchGroup()
    let service: VehicleServiceable

    init(service: VehicleServiceable) {
        self.service = service
    }

}

extension HomeViewModel {

    /// Service call of associated vehicles list to the user
    /// - Parameter completion: completion returns vehicles associated to user
    func getAsociatedVehicles(_ completion: @escaping ([Vehicle]?) -> Void) {
        Task { @MainActor in
            let result = await service.getAssociatedVehicles()
            switch result {
            case .success((let response)):
                completion(response.model.vehiclesList)
            case .failure:
                completion(nil)
            }
        }
    }
    /// Service call of getting   vehicles profiles list  of associated vehicles
    /// - Parameter completion: completion returns vehicle profile of vehicleassociated to user
    func getVehicleProfile(vehicleId: String, _ completion: @escaping ([VehicleProfile]?) -> Void) {
        Task(priority: .background) {
            let request = VehicleProfileRequest(vehicleId: vehicleId)
            let result = await service.getVehicleProfile(request: request)
            switch result {
            case .success(let response):
                if let profile = response.model.data {
                    completion(profile)
                }
            case .failure:
                completion(nil)
            }
        }
    }

    /// This method call to comple list  vehicel profiles of associated vehicles with all details
    /// - Parameter completion: completion returns vehicle profile of vehicleassociated to user
    func getVehicles(_ completion: @escaping ([VehicleProfile]) -> Void) {

        var vehicleProfiles = [VehicleProfile]()
        self.dispatchGroup.enter()
        getAsociatedVehicles { associatedVehicles in
            if var vehiclesList = associatedVehicles {
                vehiclesList = vehiclesList.filter {$0.deviceId != nil}
                vehiclesList.forEach { vehicle in
                    if vehicle.associationStatus == kAssociated {
                        self.dispatchGroup.enter()
                        self.getVehicleProfile(vehicleId: vehicle.deviceId!) { profiles in
                            if var vehicleProfile = profiles?.first {
                                let modem = ModemInfo(id: vehicle.deviceId, iccid: vehicle.iccid, imei: vehicle.imei,
                                msisdn: vehicle.msisdn, imsi: vehicle.imsi, deviceType: vehicle.deviceType,
                                state: vehicle.associationStatus, firmwareVersion: vehicle.softwareVersion)
                                  vehicleProfile.updateModem(info: modem)
                                vehicleProfile.deviceId = vehicle.deviceId
                                vehicleProfiles.append(vehicleProfile)
                            }
                            self.dispatchGroup.leave()
                        }
                    }
                }
                self.dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(vehicleProfiles)
        }
    }
}

extension HomeViewModel {

    /// This is to refresh the vehicle list
    func refreshVehicleList() {
                self.getVehicles { vehicles in
                    self.vehicles = vehicles
                    if self.vehicles.count > 0 {
                        self.vehicleNames = vehicles.map { $0.vehicleAttributes?.name ?? ""}
                        if self.vehicleNames.count > 0, let firstVehicle = self.vehicleNames.first {
                            if !self.vehicleNames.contains(self.selectedVehicle) {
                                self.selectedVehicle = firstVehicle
                            }
                            self.updateVehicleProfile(vehicles: vehicles, selectedVehicle: self.selectedVehicle)
                        }
                    }
                }
    }

      /// This is to update the selected vehicle data
    func updateVehicleProfile(vehicles: [VehicleProfile], selectedVehicle: String) {
        for vehicle in vehicles {
            if let vehicleName = vehicle.vehicleAttributes?.name, vehicleName == selectedVehicle {
                Helper.setSelectedVehicleName(name: vehicleName)
                if let devId = vehicle.deviceId {
                    Helper.setSelectedDeviceId(id: devId)
                }
                Helper.setSelectedVehicleProfile(vehicle: vehicle)
                if let vehicleId = vehicle.id {
                    Helper.setSelectedVehicleId(vehicleId: vehicleId)
                }

                break
            }
        }
    }

}
