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

// view to show the loading activity indicator while api call
struct LoadingView: View {
    var tintColor: Color = .white
    var scaleSize: CGFloat = 2.5

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black)
                .opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(scaleSize, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
                    .offset(y: 0)
            }
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)
                    .padding()
            }
            .offset(y: -50)
        }
    }
}

#Preview {
    LoadingView()
}
