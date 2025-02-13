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

/// Settings view model containing settings data
class SettingsViewModel: ObservableObject {

    @Published var headers = Header.allCases
    
    func getBuildVersion() -> String {
        return Bundle.main.releaseVersionNumberPretty
    }
}

let kAccount = "Account"
let kVehicleProfile = "Vehicle Profile"
let kHelpSupport = "Help and Support"
let kTermsOfUser = "Terms of Use"
let kPrivacyPolicy = "Privacy Policy"
let kAppVersion = "App Version"
let kSignout = "Sign Out"
let kApp = "App"

enum Header: String, CaseIterable {
    case account
    case vehicle
    case app

    var title: String {
        switch self {
        case .account:
            return kAccount
        case .vehicle:
            return kVehicle
        case .app:
            return kApp
        }
    }
    var rows: [Row] {
        switch self {
        case .account:
            return [.user]
        case .vehicle:
            return [.vehicleProfile]
        case .app:
            return [.helpSupport, .termsOfuse, .privacyPolicy, .appVersion, .signOut]
        }
    }
}

enum Row: CaseIterable {
    case user
    case vehicleProfile
    case helpSupport
    case termsOfuse
    case privacyPolicy
    case appVersion
    case signOut

    var title: String {
        switch self {
        case .user:
            return "User value"
        case .vehicleProfile:
            return kVehicleProfile
        case .helpSupport:
            return kHelpSupport
        case .termsOfuse:
            return kTermsOfUser
        case .privacyPolicy:
            return kPrivacyPolicy
        case .appVersion:
            return kAppVersion
        case .signOut:
            return kSignout
        }
    }

    var iconName: String {
        switch self {
        case .user:
            return "person"
        case .vehicleProfile:
            return "car"
        case .helpSupport:
            return "questionmark.circle"
        case .termsOfuse:
            return "doc.text"
        case .privacyPolicy:
            return "doc.text"
        case .appVersion:
            return "squareshape.dotted.squareshape"
        case .signOut:
            return "rectangle.portrait.and.arrow.right"
        }
    }
    var urlString: String {
        switch self {
        case .helpSupport:
            return "https://localhost:8080/contact-us"
        case .termsOfuse:
            return "https://localhost:8080/privacy-policy-statement"
        case .privacyPolicy:
            return "https://localhost:8080/privacy-policy-statement"
        default:
            return "https://localhost:8080/"
        }
    }
}
