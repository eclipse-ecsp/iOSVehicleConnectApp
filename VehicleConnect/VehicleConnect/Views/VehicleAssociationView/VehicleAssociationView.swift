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

/// This is to update  associate or add the vehicle to the user
struct VehicleAssociationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = VehicleAssociationViewModel(service: VehicleService())
    @State private var showLoading = false
    @State private var imei: String = ""

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                    .frame(height: 16)

                Text(kIMEIInstructions)
                    .padding(.horizontal, 16.0)

                Spacer()
                    .frame(height: 100)

                TextField("IMEI", text: $imei)
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
                    showLoading = true
                    viewModel.validateIMEI(imei) { isSuccess in
                        if isSuccess {
                            viewModel.addDevice(imei) { success in
                                showLoading = false
                                if success {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        } else {
                            showLoading = false
                        }
                    }
                }, label: {
                    Text(kAddDevce)
                        .font(.title3)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .background(Color.customBlue)
                        .foregroundColor(.white)

                })
                .frame(width: 300, height: 50, alignment: .center)
                .background(Color.customBlue)
                .background(
                    NavigationLink(destination: HomeView()) {
                        Text("Go to Association Screen")
                    }
                )

                Spacer()
            }
            if showLoading {
                LoadingView()
            }
        }
        .alert(isPresented: $viewModel.showingAlert, content: {
            Alert(title: Text(kAlertTitle), message: Text(viewModel.alertMessage))
        })
        .navigationTitle(kDeviceInstallation)
    }
}

#Preview {
    VehicleAssociationView()
}
