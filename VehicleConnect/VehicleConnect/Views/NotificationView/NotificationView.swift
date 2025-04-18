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

/// Notification view to get  display the notification alerts histort
struct NotificationView: View {
    @StateObject var viewModel =  NotificationViewModel(service: NotificationService())
    @State var isAvailable: Bool = false

    var body: some View {
        ZStack {
            ZStack {
                List {
                    Section(header: Text("Notifications")) {
                        if let alerts = viewModel.vehicleAlerts?.alerts {
                            ForEach(0..<alerts.count, id: \.self) { index in
                                let alert = alerts[index]
                                HStack {
                                    Image(systemName: "bell")
                                    VStack(alignment: .leading, spacing: 6) {
                                        if let title = alert.alertType {
                                            Text(title).bold()
                                        }
                                        if let message = alert.alertMessage {
                                            Text(String(message))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if !isAvailable {
                NoNotificationsView()
            }
        }
        .alert(isPresented: $viewModel.showingAlert, content: {
            Alert(title: Text(kAlertTitle), message: Text(viewModel.alertMessage))
        })
        .onAppear {
            viewModel.vehicleAlerts?.alerts.removeAll()
            isAvailable = false
            viewModel.getNotifications { success in
                DispatchQueue.main.async {
                    if success {
                        if let alerts = viewModel.vehicleAlerts?.alerts {
                            if !alerts.isEmpty {
                                isAvailable = false
                            }
                        }
                        isAvailable = true
                    }
                }
            }
            let token = Helper.getDeviceToken()
            let isTokenShared = Helper.getIsDeviceTokenShared()
            if !token.isEmpty && !isTokenShared {
                viewModel.shareDeviceToken { success in
                    if success {
                        Helper.setIsDeviceTokenShared(isShared: true)
                        print("device token is shared")
                    }

                }
            }
        }

    }
}

#Preview {
    NotificationView()
}
