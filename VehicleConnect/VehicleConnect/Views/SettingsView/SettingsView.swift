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

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

import SwiftUI
import VehicleConnectSDK

/// settings view
struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @StateObject var userViewModel = SignInViewModel(service: UserService())
    @StateObject var homeViewModel = HomeViewModel(service: VehicleService())

    @EnvironmentObject var appAuthentication: AppAuthentication
    @State private var showLoading = false
    @State private var showingAlert = false
    @State private var showingChangePasswordAlert = false
    @State private var userEmail = Helper.getUserEmail()
    @State private var selectedVehicle = Helper.getSelectedVehicleName()

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.headers, id: \.title) { header in
                    Section(header: Text(header == .vehicle ? selectedVehicle : header.title)) {
                        ForEach(header.rows, id: \.title) { row in
                            HStack {
                                Image(systemName: row.iconName)
                                    .frame(width: 25, height: 25)
                                switch row {
                                case .user:
                                    Text(userEmail)
                                        .font(.subheadline)
                                case .changePassword:
                                    Button(action: {
                                        self.showLoading = true
                                        userViewModel.changePassword { isSuccess in
                                            if isSuccess {
                                                self.showingChangePasswordAlert = true
                                            }
                                            self.showLoading = false
                                        }
                                    }, label: {
                                        Text(row.title)
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                    })
                                case .helpSupport, .privacyPolicy, .termsOfuse:
                                    Text(row.title)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                case .vehicleProfile:
                                    NavigationLink(destination: VehicleProfileView()) {
                                        Text(row.title)
                                            .font(.subheadline)
                                    }
                                case .appVersion:
                                    Text(row.title)
                                        .font(.subheadline)
                                    Spacer()
                                    Text(viewModel.getBuildVersion())
                                case .signOut:
                                    Button(action: {
                                        self.showingAlert = true
                                    }, label: {
                                        Text(row.title)
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                    })
                                }
                            }
                        }
                    }
                }
            }
            if showLoading {
                LoadingView()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(kAlertTitle),
                message: Text(kSignOutMessage),
                primaryButton: .destructive(Text(kSignOut)) {
                    userViewModel.signout { isSuccess in
                        if isSuccess {
                            self.appAuthentication.updateValidation(success: false)
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showingChangePasswordAlert, content: {
            Alert(title: Text(kAlertTitle), message: Text(kChangePasswordSuccess))
        })
        .onAppear {
            selectedVehicle = Helper.getSelectedVehicleName()
            userEmail = Helper.getUserEmail()
            if selectedVehicle.isEmpty  || userEmail.isEmpty {
                homeViewModel.refreshVehicleList()
                userViewModel.getProfile { responseModel in
                    if let userId = responseModel?.id {
                        Helper.setUserId(userId: userId)
                    }
                    if let email = responseModel?.email {
                        Helper.setUserEmail(email: email
                        )}
                }
            }
        }

    }
}

#Preview {
    SettingsView()
        .environmentObject(AppAuthentication())
}
