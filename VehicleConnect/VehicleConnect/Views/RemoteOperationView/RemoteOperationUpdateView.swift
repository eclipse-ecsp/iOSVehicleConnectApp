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
import SwiftUI
import VehicleConnectSDK

/// This is the sub view of RO settings 
struct RemoteOperationUpdateView: View {
    @State var command: RemoteCommandDataModel
    @State var selectedOption: RemoteCommandOption?
    @State var remoteSelectedOption: RemoteCommandOption?
    @Binding var showingOptions: Bool
    @State var viewModel: RemoteOperationViewModel
    @State var isEnabledApplyButton = false

    var body: some View {
        VStack {
            VStack {
                GeometryReader { geometer in
                    VStack {
                        Button("", action: {
                                command.options.forEach { item in
                                    if item.id == remoteSelectedOption?.id {
                                        item.isSelected = true
                                    } else {
                                        item.isSelected = false
                                    }
                                }
                        })
                        .frame(width: geometer.size.width, height: geometer.size.height, alignment: .center)
                        .background(Color.black)
                        .opacity(0.3)
                        .onTapGesture {
                            showingOptions = false
                            command.options.forEach { item in
                                if command.stateValue == item.optionValue {
                                    item.isSelected = true
                                } else {
                                    item.isSelected = false
                                }
                            }

                        }
                    }
                }
            } .background(Color.black)
                .opacity(0.3)
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            HStack {
                                Spacer(minLength: 2)
                                Text("windows")
                                Spacer(minLength: geometry.size.width - 150)
                                VStack {
                                    Button("Apply", action: {
                                        var percent: Int?
                                        if command.stateType == .windows {
                                            percent = 60
                                        }
                                        if let state = selectedOption?.optionValue {
                                           let requestData = RemoteEventUpdateData(state: state,
                                            percent: percent, duration: 8)
                                            viewModel.updateROSettings(command.stateType, requestData)
                                            showingOptions = false
                                        }
                                    })
                                    .opacity(0.5)
                                    .foregroundColor(isEnabledApplyButton ? .customBlue: .gray)
                                    .disabled(!isEnabledApplyButton)
                                    .fontWeight(.bold)
                                }
                                .foregroundColor(.gray)
                                Spacer(minLength: 2)
                            }
                            Spacer()
                            Divider()
                            HStack {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        ForEach(command.options) { item in
                                            let minCount = CGFloat(command.options.count*50)
                                            LazyVGrid(columns: [GridItem(.adaptive(minimum: minCount))], spacing: 16) {
                                                Button(action: {
                                                    var checked: RemoteCommandOption?
                                                    command.options.forEach { element in
                                                    element.isSelected = false
                                                    }
                                                    item.isSelected = true
                                                    checked = item
                                                    self.selectedOption = checked
                                                    isEnabledApplyButton = true
                                                    if item.id == remoteSelectedOption?.id {
                                                        isEnabledApplyButton = false
                                                    }

                                                }, label: {
                                                    VStack {
                                                        Image(systemName: item.icon).frame(width: 50, height: 50)
                                                            .foregroundColor(item.isSelected ? .customBlue: .gray)
                                                        Text(item.optionValue.title).font(.system(size: 14))
                                                            .foregroundColor(item.isSelected ? .customBlue: .gray)

                                                    }

                                                })
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .background(Color.clear.ignoresSafeArea())
                        .frame(width: geometry.size.width, height: 150)

                    }
                }

            }
            .frame(minWidth: UIScreen().bounds.size.width, maxWidth: .infinity, minHeight: 100, maxHeight: 150)
            .background(Color.clear)
            Divider()

        }
        .onAppear {
            command.options.forEach { item in
                if command.stateValue == item.optionValue {
                    item.isSelected = true
                    self.remoteSelectedOption = item
                    self.selectedOption = item
                } else {
                    item.isSelected = false
                }
            }
        }

    }
}
