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

///  Remote operation view model containg Service calls and data logic to display and update the ro setting
class RemoteOperationViewModel: ObservableObject {
    let service: RemoteOperationServiceable
    @Published var showingROAlert = false
    @Published var showingAlert = false
    @Published var showLoading = false
    @Published var history: [RemoteEventHistory]?
    @Published var alertMessage = ""
    let kDefaultDuration = 180.0
    var maxRetryCount = 30
    var statusTime = 10

    var commandData: [RemoteCommandDataModel] =  []

    init(service: RemoteOperationServiceable) {
        self.service = service
    }

    /// Service call to get the RO settings History this API is called inetially to get list of setting to diplay
    /// - Parameter completion:On completion it recieve the data models and raw data or error
    func getROHistory(_ completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let userId = Helper.getUserId()
            let vehicleId = Helper.getSelectedDeviceId()
            let roRequest = RemoteOperationHistoryRequest(userId: userId, vehicleId: vehicleId)
            let result = await service.getROHistory(roRequest)
            switch result {
            case .success(let response):
                handleHistory(response: response)
                completion(true)
            case .failure(let error):
                handleErrorMessage(error)
                completion(false)
            }
        }
    }

    /// Service call to get the RO settings History which is requested  based on request Id
    /// - Parameter completion:On completion it recieve the data models
    ///  of history of particular setting  and raw data or error
    func getRORequest(_ stateType: RemoteEventStateType, _ requestId: String, _ completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let userId = Helper.getUserId()
            let vehicleId = Helper.getSelectedDeviceId()
            let roRequest = RemoteEventStatusRequest(userId: userId, vehicleId: vehicleId, reuestId: requestId)
            let result = await service.getRORequest(roRequest)
            switch result {
            case .success(let response):
                handleRequestStatus(response.model, stateType)
                completion(true)
                self.showLoading = false
            case .failure(let error):
                handleErrorMessage(error)
                completion(false)
            }
        }
    }

    /// Service call to update the RO settings
    /// - Parameter completion:On completion it recieve the data model containg requestId  and raw data or error
    func setRORequest( _ stateType: RemoteEventStateType, _ postdata: RemoteEventUpdateData,
                       _ completion: @escaping (Bool, String) -> Void) {
        Task { @MainActor in
            let userId = Helper.getUserId()
            let vId = Helper.getSelectedDeviceId()
            let roRequest = RemoteEventUpdateRequest(userId: userId, vehicleId: vId,
                                                     stateType: stateType, postData: postdata)
            let result = await service.setRORequest(roRequest)
            switch result {
            case .success(let response):
                if let requestId = response.model.requestId {
                    completion(true, requestId)
                } else {
                    completion(false, "")
                }
            case .failure(let error):
                handleErrorMessage(error)
                completion(false, "")
            }
        }
    }

    private func handleHistory(response: Response<[RemoteEventHistory]>) {
        self.history = response.model
        let commands = (response.model.filter { $0.roStatus == .success || $0.roStatus == .pending })
        for command in commands where command.roStatus != nil {
            self.updateCommand(command, command.roStatus!)
        }
    }

    private func handleErrorMessage(_ error: CustomError) {
        alertMessage = error.message
        if !alertMessage.isEmpty {
            showingAlert = true
        }
        self.showLoading = false
    }

    /// This is called from RemoteOperationView to update the settings
    func updateROSettings(_ stateType: RemoteEventStateType, _ postdata: RemoteEventUpdateData) {
        showLoading = true
        setRORequest(stateType, postdata) { success, requestId in
            if success {
                self.roCommandRequest(stateType, requestId, self.maxRetryCount)
            } else {
                self.showLoading = false
            }

        }
    }

    /// This call function call the get the current status of  particulaer setting 
    /// unit its setting updated to succes or failed,
    func roCommandRequest(_ stateType: RemoteEventStateType, _ requestId: String, _ retryCount: Int) {
            self.getRORequest(stateType, requestId) { success in
                if success {
                    self.showLoading = false
                } else {

                }
        }
    }

    /// This function is to handel  update the current status of RO setting
    ///  after getting the response of get request service  call
    private func  handleRequestStatus(_ roHisrory: RemoteEventHistory, _ stateType: RemoteEventStateType ) {
        switch roHisrory.roStatus {
        case .success:
            // update the UI when get request succeeded
            updateCommand(roHisrory, .success)
        case .pending:
            let currentTime = Date().timeIntervalSince1970
            let apiTime = TimeInterval(roHisrory.roEvent.timestamp / 1000)
            let difference = currentTime - apiTime
            if difference > kDefaultDuration {
                    updateCommand(roHisrory, .pending)
                showingAlert = true
                alertMessage = stateType.rawValue.uppercased() + kRemoteOperationFailed
               } else {
                /// repaet unill succes or failed to get the real status
                if maxRetryCount > 0 {
                    maxRetryCount -= 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.statusTime)) {
                        self.roCommandRequest(stateType, roHisrory.roEvent.roDetail.roRequestId, self.maxRetryCount)
                    }
                }
                updateCommand(roHisrory, .pending)
            }
        case .ttlExpired, .failed:
            /// setting is updated to pevious status if failed  by calling the get history api again
            self.showLoading = true
            getROHistory { _ in
                if let command = (self.commandData.first { $0.id == roHisrory.roEvent.eventId }) {
                    command.commandStatus = .success
                }
                self.showLoading = false
            }
        case .none:
            break
        }

    }

    /// Update command function is to  update the RoO UI data model acording to the actual status
    private func updateCommand(_ commandHistory: RemoteEventHistory, _ status: RemoteCommandStatus) {
        if let value = RemoteEventStateValue(rawValue: commandHistory.roEvent.roDetail.state), let command = (commandData.first { $0.id == commandHistory.roEvent.eventId }) {
            if status == .pending {
                let currentTime = Date().timeIntervalSince1970
                let apiTime = TimeInterval(commandHistory.roEvent.timestamp / 1000)
                let difference = currentTime - apiTime
                command.commandStatus = difference < kDefaultDuration ? .pending : .success
            } else {
                command.commandStatus = .success
                command.stateValue = value
                if command.stateType == .windows || command.stateType == .lights {
                    command.options.forEach { item in
                        item.isSelected = (command.stateValue == item.optionValue)
                    }
                }
            }
        }
    }

    /// This is to display the alert while chaging the settings by user
    func setAlertMessage(command: RemoteCommandDataModel) {
        let type = command.stateType
        let value = command.stateValue
        switch type {
        case .alarm:
            showingROAlert = true
            alertMessage = kMessageSignalAlarm + " " + changedState(state: value, stateType: type).alertTitle
        case .doors:
            showingROAlert = true
            alertMessage = kMessageDoor + " " + changedState(state: value, stateType: type).alertTitle
        case .engine:
            showingROAlert = true
            alertMessage = kMessageEngine + " " + changedState(state: value, stateType: type).alertTitle
        case .trunk:
            showingROAlert = true
            alertMessage = kMessageTrunk + " " + changedState(state: value, stateType: type).alertTitle
        default:
            showingROAlert = false
        }
    }

    /// This is to update the state of RO data model object
    func changedState(state: RemoteEventStateValue, stateType: RemoteEventStateType) -> (RemoteEventStateValue) {
        switch stateType {
        case .alarm:
            if  state == .stateOff {
                return (.stateOn)
            } else {
                return (.stateOff)
            }

        case .doors, .trunk:
            if  state == .locked {
                return .unlocked
            } else {
                return.locked
            }

        case .engine:
            if  state == .started {
                return .stopped
            } else {
                return .started
            }
        default:
            return .stateOff
        }
    }

    /// This is to prepare the request  data for  set RO setting service call
    func updateSettings(command: RemoteCommandDataModel?) {
        var percent: Int?
        var duration: Int?
        switch command?.stateType {
        case .alarm:
            percent = nil
            duration = 60
        case .doors, .trunk:
            percent = nil
            duration = nil
        case .engine:
            percent = nil
            duration = 8
        default:
            percent = nil
            duration = 8
        }
        if let stateType = command?.stateType, let state = command?.stateValue {
            let stateValue = changedState(state: state, stateType: stateType)
            let requestData = RemoteEventUpdateData(state: stateValue, percent: percent, duration: duration)
            self.showLoading = true
            updateROSettings(stateType, requestData)
        }
    }
}

/// This is to notify when Vehicle is changed to fetch the current vehicle data
extension RemoteOperationViewModel {

        func addVehicleChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onVehicleChange),
        name: Notification.Name(kVehicleChange), object: nil)
        }

        @objc private func onVehicleChange(_ notification: NSNotification) {
            getROHistory { isSuccess in
                print("onVehicleChange RO History: \(isSuccess)")
            }
        }
        func removeVehicleChangeNotification() {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(kVehicleChange), object: nil)
        }
    }
