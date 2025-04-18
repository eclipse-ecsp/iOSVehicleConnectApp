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
import UIKit

/// SignIn View model containing service call and business logics
class SignInViewModel: ObservableObject {

    @Published var showingAlert = false
    @Published var alertMessage = ""

    let service: UserServiceable

    init(service: UserServiceable) {
        self.service = service
    }
}

extension SignInViewModel {

    /// SIgnIn service call
    func signIn(_ completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            if let vc = UIApplication.shared.rootViewController {
                let result = await self.service.signInWithAppAuth(vc)
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    switch error {
                    case .environmentNotConfigured, .notRechable:
                        showingAlert = true
                        alertMessage = error.message
                    default:
                        showingAlert = false
                    }
                    completion(false)
                }
            }
        }
    }

    /// SignUp service call
    func signUp(_ completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            if let vc = UIApplication.shared.rootViewController {
                let result = await service.signUpWithAppAuth(vc)
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    switch error {
                    case .environmentNotConfigured, .notRechable:
                        showingAlert = true
                        alertMessage = error.message
                    default:
                        showingAlert = false
                    }
                    completion(false)
                }
            }
        }
    }

    /// Signout service call
    func signout(_ completion: @escaping (Bool) -> Void) {
        showingAlert = false
        Task { @MainActor in
            let result = await service.signOutWithAppAuth()
            switch result {
            case .success:
                Helper.removeAllData()
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

    ///  Get user prfile service  call
    func getProfile(_ completion: @escaping (UserProfile?) -> Void) {
        Task(priority: .background) {
            let result = await service.getUserProfile()
            switch result {
            case .success(let response):
                completion(response.model)
            case .failure:
                completion(nil)
            }
        }
    }

    ///  Change password service  call
    func changePassword(_ completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let result = await service.changePassword()
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    /// Check token is valid
    func isNotValidToken() -> Bool {
        return service.isAuthorizationExpired()
    }

    /// Getting refresh token
    func refreshToken(_ completion: @escaping (Bool) -> Void) {
        Task(priority: .background) {
            let result = await service.refreshAccessToken()
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }

}
