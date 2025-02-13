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

/// Custom data model to display RO settiings options
class RemoteCommandDataModel: Identifiable {

    var id: String
    var name: String
    var stateType: RemoteEventStateType
    var stateValue: RemoteEventStateValue
    var options: [RemoteCommandOption]
    var commandStatus: RemoteCommandStatus

    init(id: String, name: String, stateType: RemoteEventStateType, stateValue: RemoteEventStateValue,
         options: [RemoteCommandOption], commandStatus: RemoteCommandStatus) {
        self.id = id
        self.name = name
        self.stateType = stateType
        self.stateValue = stateValue
        self.options = options
        self.commandStatus = commandStatus
    }

    var icon: String {
        var imageName = ""
        switch self.stateType {
        case .windows:
            imageName = "car.window.right"
        case .lights:
            imageName = "headlight.fog"
        case .alarm:
            imageName = "horn"
        case .doors:
            imageName = "lock"
        case .engine:
            imageName = "power"
        case .trunk:
            imageName = "truck.pickup.side.front.open"
        default:
            imageName = ""
        }
        return imageName
    }

}

/// Sub option of RO command
class RemoteCommandOption: Identifiable {
    var  id: Int
    var  optionValue: RemoteEventStateValue
    var  isSelected: Bool
    init(id: Int, optionValue: RemoteEventStateValue, isSelected: Bool) {
        self.id = id
        self.optionValue = optionValue
        self.isSelected = isSelected
    }
    var icon: String {
        var imageName = ""
        switch self.optionValue {
        case .closed:
            imageName = "arrowtriangle.up.arrowtriangle.down.window.right"
        case .ajar:
            imageName = "car.window.right.badge.xmark"
        case .opened:
            imageName =  "car.window.right"
        case .stateOn:
            imageName = "headlight.fog.fill"
        case .stateOff:
            imageName = "headlight.fog"
        default:
            imageName = ""
        }
        return imageName
    }

}

extension RemoteOperationViewModel {

    /// List of sub options of particler settings
    var windowsOptions: [RemoteCommandOption] {
        [
            .init(id: 0, optionValue: .closed, isSelected: true),
            .init(id: 1, optionValue: .ajar, isSelected: false),
            .init(id: 2, optionValue: .opened, isSelected: false)
        ]
    }

    /// List of loghts options
    var lightsOptions: [RemoteCommandOption] {
        [
            .init(id: 0, optionValue: .stateOn, isSelected: false),
            .init(id: 1, optionValue: .stateOff, isSelected: true)
        ]
    }

    func confifureRemoteOperationData() {
        /// list of remote operations
        let window =  RemoteCommandDataModel.init(id: "RemoteOperationWindows", name: "Windows", stateType: .windows,
                      stateValue: .closed, options: windowsOptions, commandStatus: .success)
        commandData.append(window)
        let lights =  RemoteCommandDataModel.init(id: "RemoteOperationLights", name: "Lights", stateType: .lights,
                      stateValue: .stateOff, options: lightsOptions, commandStatus: .success)
        commandData.append(lights)
        let  alarm = RemoteCommandDataModel.init(id: "RemoteOperationAlarm", name: "Alarm", stateType: .alarm,
                     stateValue: .stateOff, options: [], commandStatus: .success)
        commandData.append(alarm)
        let door = RemoteCommandDataModel.init(id: "RemoteOperationDoors", name: "Door", stateType: .doors,
                   stateValue: .locked, options: [], commandStatus: .success)
        commandData.append(door)
        let engine = RemoteCommandDataModel.init(id: "RemoteOperationEngine", name: "Engine", stateType: .engine,
                     stateValue: .stopped, options: [], commandStatus: .success)
        commandData.append(engine)
        let trunk = RemoteCommandDataModel.init(id: "RemoteOperationTrunk", name: "Trunk", stateType: .trunk,
                    stateValue: .locked, options: [], commandStatus: .success)
        commandData.append(trunk)
    }

}

// Different state of settings , getting title and alert title
extension RemoteEventStateValue {
        public var title: String {
            switch self {
            case .stateOn:
                return "on"
            case .stateOff:
                return "off"
            case .flash:
                return "flash"
            case .locked:
                return "locked"
            case .unlocked:
                return "unlocked"
            case .stopped:
                return "stopped"
            case .started:
                return "started"
            case .closed:
                return "closed"
            case .opened:
                return "opened"
            case .ajar:
                return "ajar"
            }
        }

        public var alertTitle: String {
            switch self {
            case .stateOn:
                return "on"
            case .stateOff:
                return "off"
            case .flash:
                return "flash"
            case .locked:
                return "lock"
            case .unlocked:
                return "unlock"
            case .stopped:
                return "stop"
            case .started:
                return "start"
            case .closed:
                return "close"
            case .opened:
                return "open"
            case .ajar:
                return "ajar"
            }
        }

}
