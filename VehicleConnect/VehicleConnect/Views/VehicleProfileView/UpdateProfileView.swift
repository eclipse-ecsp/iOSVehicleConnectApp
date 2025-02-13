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

/// update vehicle profile name view
struct UpdateProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = VehicleProfileViewModel(service: VehicleService())
    @State private var showLoading = false
    @Binding  var vehicleProfile: VehicleProfile?
    @State private var vehicleName: String = ""

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                    .frame(height: 16)

                Spacer()
                    .frame(height: 100)

                TextField(kNickname, text: $vehicleName)
                    .padding(.leading, 16)
                    .padding(.horizontal, 16)
                    .foregroundColor(Color.customBlue)

                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)

                Spacer()
                    .frame(height: 30)
                Button(action: {
                     if let vehicleId = vehicleProfile?.id {
                        showLoading = true
                        viewModel.updateVehicleName(vehicleName, vehicleId) { isSuccess in
                            if isSuccess {
                                showLoading = false
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }, label: {
                    Text(kSave)
                        .font(.title3)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .background(Color.customBlue)
                        .foregroundColor(.white)

                })
                .frame(width: 300, height: 50, alignment: .center)
                .background(Color.customBlue)
                Spacer()

            }
            if showLoading {
                LoadingView()
            }

        }
        .alert(isPresented: $viewModel.showingAlert, content: {
            Alert(title: Text(kAlertTitle), message: Text(viewModel.alertMessage))
        })
        .navigationTitle(kNickname)
        .onAppear {
            vehicleName = (vehicleProfile?.vehicleAttributes?.name ?? kNA)

        }
    }
}

// #Preview {
//    // UpdateProfileView()
// }
