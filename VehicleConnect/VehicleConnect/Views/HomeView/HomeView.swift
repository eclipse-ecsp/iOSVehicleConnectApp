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

enum Tab: String, CaseIterable, Identifiable {
    case remoteOp
    case settings

    var id: Self { self }
}
/// Home view is bacially a tabbar view containing the main view like settings and Remote operations view
struct HomeView: View {
    let screenWidth = UIScreen.main.bounds.width
    @State private var tab = Tab.remoteOp
    @StateObject var viewModel = HomeViewModel(service: VehicleService())
    @StateObject var userViewModel = SignInViewModel(service: UserService())
    @State private var showLoading = false
    @EnvironmentObject var appAuthentication: AppAuthentication
  //  @State private var navigated = false
   // @State var timer: Timer?

    var body: some View {
        ZStack {
            NavigationStack {
                TabView(selection: $tab) {
                    RemoteOperationView()
                        .tabItem {
                            VStack {
                                Image(systemName: "car")
                                Text(kRemoteControls)
                            }
                        }.tag(Tab.remoteOp)
                    SettingsView()
                        .tabItem {
                            VStack {
                                Image(systemName: "gearshape")
                                Text(kSettings)
                            }
                        }.tag(Tab.settings)
                }

                .toolbarRole(.editor)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitle("", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Menu(viewModel.selectedVehicle) {
                            VStack {
                                ForEach(viewModel.vehicleNames, id: \.self) { vehicleName in
                                    Button {
                                        viewModel.selectedVehicle = vehicleName
                                        viewModel.updateVehicleProfile(vehicles: viewModel.vehicles,
                                                                       selectedVehicle: vehicleName)
                                        NotificationCenter.default.post(name: Notification.Name(kVehicleChange),
                                                                        object: nil, userInfo: nil)

                                    } label: {
                                        Text(vehicleName)
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    if userViewModel.isNotValidToken() {
                        userViewModel.refreshToken { success in
                            if success {
                                viewModel.refreshVehicleList()
                            } else {
                                userViewModel.signout { isSuccess in
                                    if isSuccess {
                                        self.appAuthentication.updateValidation(success: false)
                                    }
                                }
                            }
                        }
                    } else {
                        viewModel.refreshVehicleList()
                        userViewModel.getProfile { responseModel in
                            if let userId = responseModel?.id {
                                Helper.setUserId(userId: userId)
                            }
                            if let email = responseModel?.email {
                                Helper.setUserEmail(email: email)
                                NotificationCenter.default.post(name: Notification.Name(kVehicleChange),
                                                                object: nil, userInfo: nil)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppAuthentication())

}
