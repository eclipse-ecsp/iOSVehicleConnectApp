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

enum DropDownPickerState {
    case top
    case bottom
}

struct DropDownPicker: View {

    @Binding var selection: String?
    var state: DropDownPickerState = .bottom
    var options: [String]
    var maxWidth: CGFloat = 100
    var borderColor: Color = .white

    @State var showDropdown = false

    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State var zindex = 1000.0

    var body: some View {
        GeometryReader {
            let size = $0.size

            VStack(spacing: 0) {

                if state == .top && showDropdown {
                    optionsView()
                }

                HStack {
                    Text(selection == nil ? "Select" : selection!)
                        .foregroundColor(selection != nil ? Color.customBlue : .gray)
                        .bold()

                    Spacer(minLength: 0)

                }
                .padding(.horizontal, 10)
                .frame(width: maxWidth, height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    index += 1
                    zindex = index
                    withAnimation(.snappy) {
                        showDropdown.toggle()
                    }
                }
                .zIndex(10)

                if state == .bottom && showDropdown {
                    optionsView()
                }
            }
            .clipped()
            .cornerRadius(10)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(borderColor)
                            }
            .frame(height: size.height, alignment: state == .top ? .bottom : .top)

        }
        .frame(width: maxWidth, height: 50)
        .zIndex(zindex)
    }

    func optionsView() -> some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                HStack {
                    Text(option)
                    Spacer()
                    Image(systemName: "checkmark")
                        .opacity(selection == option ? 1 : 0)
                }
                .foregroundStyle(selection == option ? Color.primary : Color.gray)
                .animation(.none, value: selection)
                .frame(height: 40)
                .contentShape(.rect)
                .padding(.horizontal, 10)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selection = option
                        showDropdown.toggle()
                    }
                }
            }
        }
        .transition(.move(edge: state == .top ? .bottom : .top))
        .zIndex(1)
    }
}
