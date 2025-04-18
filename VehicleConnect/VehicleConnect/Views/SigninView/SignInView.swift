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

/// Signin view
struct SignInView: View {

    let screenWidth = UIScreen.main.bounds.width

    @EnvironmentObject var appAuthentication: AppAuthentication
    @StateObject var environmentConfiguration = EnvironmentConfiguration()
    @StateObject var viewModel = SignInViewModel(service: UserService())

    @State private var selection: String? = ""
    @State private var showLoading = false
    @Environment(\.openURL) var openURL

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    DropDownPicker(selection: $selection.onChange({ value in
                        if let environmentName = value {
                            environmentConfiguration.selectEnvironment(name: environmentName)
                        }
                    }), options: environmentConfiguration.names, maxWidth: 130, borderColor: Color.customBlue )
                   // .disabled(true)

                }.zIndex(1)
                Spacer()
                Text("Vehicle Connect")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .frame(width: screenWidth, height: 50)
                    .foregroundColor(Color.customBlue)
                Spacer()

                VStack(alignment: .leading) {
                    Button(action: {
                        showLoading = true
                        viewModel.signIn { isSuccess in
                                if isSuccess {
                                    appAuthentication.updateValidation(success: true)
                                }
                                showLoading = false
                        }
                    }, label: {
                        Text(kSignIn)
                            .font(.title3)
                            .fontWeight(.heavy)
                            .frame(width: screenWidth, height: 50)
                            .foregroundColor(Color.customBlue)
                    })

                    Button(action: {
                        showLoading = true
                        viewModel.signUp { isSuccess in
                                if isSuccess {
                                   // appAuthentication.updateValidation(success: true)
                                }
                                showLoading = false
                        }
                    }, label: {
                        Text(kSignUp)
                            .font(.title3)
                            .fontWeight(.heavy)
                            .frame(width: screenWidth, height: 50)
                            .foregroundColor(.white)
                    })
                    .background(Color.customBlue)
                }

            }
            .padding()
            if showLoading {
                LoadingView()
            }
        }
        .alert(isPresented: $viewModel.showingAlert, content: {
            Alert(title: Text(kAlertTitle), message: Text(viewModel.alertMessage))
        })
        .onAppear {

            if !environmentConfiguration.names.isEmpty, let name = environmentConfiguration.names.first {
                selection = name
                environmentConfiguration.selectEnvironment(name: name)
            }
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AppAuthentication())
}
