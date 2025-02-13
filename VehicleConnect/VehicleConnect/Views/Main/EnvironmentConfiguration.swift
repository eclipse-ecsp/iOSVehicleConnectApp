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
import VehicleConnectSDK

/// This select the decite the current and selected environment of the app
class EnvironmentConfiguration: ObservableObject, Mockable {

    @Published var selectedEnvironment: EnvironmentDetail?
    @Published var names = [String]()

    private var environments = [EnvironmentDetail]()

    init() {
        loadEnvironment()
    }

    func loadEnvironment() {
        environments = loadJSON(filename: "environment", type: [EnvironmentDetail].self)
        names = environments.map {$0.title}
    }

    func selectEnvironment(name: String) {
        if let environment = environments.filter({$0.title == name}).first {
            selectedEnvironment = environment
            AppManager.configure(environment)
        }
    }
}
