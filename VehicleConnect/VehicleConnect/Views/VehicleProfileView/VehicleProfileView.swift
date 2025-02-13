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

import SwiftUI

import VehicleConnectSDK

/// View to display the vehicles properties
struct VehicleProfileView: View {

    @State public var vehicleProfile: VehicleProfile?
    @State  private var make: String = kNA
    @State  private var model: String = kNA
    @State  private var year: String = kNA

    var body: some View {
        List {
            Section(kVehicle) {
                VStack(alignment: .leading) {
                    Text(kVin)
                        .font(.subheadline)
                    Text(vehicleProfile?.vin ?? kNA)
                        .font(.footnote)
                }
                VStack(alignment: .leading) {
                    Text(kNickname)
                        .font(.subheadline)
                    Text(vehicleProfile?.vehicleAttributes?.name ?? kNA)
                        .font(.footnote)
                }

                VStack(alignment: .leading) {
                    Text(kMakeModelYear)
                        .font(.subheadline)
                    Text("\(make) \(model) \(year)")
                        .font(.footnote)
                }
                VStack(alignment: .leading) {
                    Text(kColor)
                        .font(.subheadline)
                    Text(vehicleProfile?.vehicleAttributes?.baseColor ?? kNA)
                        .font(.footnote)
                }
            }
            Section(kVehicleConnectDevice) {
                VStack(alignment: .leading) {
                    Text(kState)
                        .font(.subheadline)
                    Text((vehicleProfile?.modemInfo?.state == vAssociated ? vActive:
                    vehicleProfile?.modemInfo?.state) ?? kNA)
                        .font(.footnote)
                }

                VStack(alignment: .leading) {
                    Text(kImei)
                        .font(.subheadline)
                    Text(vehicleProfile?.modemInfo?.imei ?? kNA)
                        .font(.footnote)
                }
                VStack(alignment: .leading) {
                    Text(kImsi)
                        .font(.subheadline)
                    Text(vehicleProfile?.modemInfo?.imsi ?? kNA)
                        .font(.footnote)
                }
                VStack(alignment: .leading) {
                    Text(kSoftwareVersion)
                        .font(.subheadline)
                    Text(vehicleProfile?.modemInfo?.firmareVersion ?? kNA)
                        .font(.footnote)
                }
            }
        }
        .navigationTitle(kVehicleProfile)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let profile = Helper.getSelectedVehicleProfile() {
                vehicleProfile = profile
                if let makeValue = vehicleProfile?.vehicleAttributes?.make {
                    make  = makeValue
                }
                if let modelValue = vehicleProfile?.vehicleAttributes?.model {
                    model  = modelValue
                }
                if let modelYearValue = vehicleProfile?.vehicleAttributes?.modelYear {
                    year  = modelYearValue
                }
            }
        }
    }
}

#Preview {
    VehicleProfileView()
}
