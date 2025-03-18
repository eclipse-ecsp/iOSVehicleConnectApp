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

/// Remote operations main view containing  different type of RO settings
struct RemoteOperationView: View {

    @StateObject var viewModel = RemoteOperationViewModel(service: RemoteOperationService())
    @State var showingOptions = false
    @State var selectedCommand: RemoteCommandDataModel?
    @State private var showLoading = false
    @State var updater: Bool = false

    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 100))
    ]
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    Spacer()
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                        ForEach(viewModel.commandData) { item in
                            VStack {
                                Button(action: {
                                    switch item.stateType {
                                    case .windows, .lights:
                                        self.showingOptions = true
                                        self.selectedCommand = item
                                    case .alarm, .doors, .engine, .trunk:
                                        self.selectedCommand = item
                                        viewModel.setAlertMessage(command: item)
                                    default:
                                        self.showingOptions = false
                                    }
                                }, label: {
                                    customROButton(command: item)
                                })
                                .padding()
                                .foregroundColor(item.stateValue == .stateOff || item.stateValue == .locked
                                || item.stateValue == .closed || item.stateValue == .stopped ? .gray : .blue)
                                .frame(width: 100, height: 100, alignment: .center)
                                Spacer()
                            }
                            .frame(width: 100, height: 100, alignment: .top)
                            .overlay( (item.id == selectedCommand?.id && showingOptions) ?
                                      RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.customBlue, lineWidth: 2)
                                      :  RoundedRectangle(cornerRadius: 16)
                                .stroke(.gray, lineWidth: 2)
                            )
                        }
                    }
                }.padding()
            }
            if self.showingOptions {
                if let selectedCommand = selectedCommand {
                    if selectedCommand.stateType == .windows || selectedCommand.stateType == .lights {
                        RemoteOperationUpdateView(command: selectedCommand,
                                                  showingOptions: $showingOptions, viewModel: viewModel)
                    }
                }
            }
            if viewModel.showLoading {
                LoadingView()
            }
        }
        .alert(kAlertTitle, isPresented: $viewModel.showingROAlert) {
            Button(kConfirm) {
                viewModel.updateSettings(command: selectedCommand)
            }
            Button(kCancel, role: .cancel) {
                print("Cancel the action")
            }
        } message: {
            Text(viewModel.alertMessage)
        }
        
        .alert(isPresented: $viewModel.showingAlert, content: {
            Alert(title: Text(kAlertTitle), message: Text(viewModel.alertMessage))
        })
        .onAppear {
            viewModel.addVehicleChangeNotification()
            viewModel.showingAlert = false
            viewModel.showingROAlert = false
            viewModel.commandData.removeAll()
            viewModel.confifureRemoteOperationData()
            if AppAuthentication().isSignInValidated {
                if !Helper.getUserId().isEmpty && !Helper.getSelectedDeviceId().isEmpty {
                    self.showLoading = true
                    viewModel.getROHistory { success in
                    if success {
                        updater.toggle()
                    }
                    self.showLoading = false
                }
              }
            }
        }
        .onDisappear {
            viewModel.removeVehicleChangeNotification()
        }

    }
}

/// custom so settings button 
private func customROButton(command: RemoteCommandDataModel) -> some View {
    let state: RemoteEventStateValue = command.stateValue
    return HStack(alignment: .center, spacing: 5.0) {
        VStack {
            Image(systemName: command.icon).frame(width: 40, height: 40)
                .foregroundColor(state == .stateOff || state == .locked  || state == .closed || state == .stopped ?
                    .gray : .customBlue)
            Text(command.commandStatus == .pending ? kStatusPending : command.stateValue.title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(state == .stateOn || state == .unlocked  || state == .opened || state == .started
                             || command.commandStatus == .pending ? .customBlue : .gray)

            Text(command.name).font(.system(size: 14))
        }
    }
}

#Preview {
    RemoteOperationView()
}
