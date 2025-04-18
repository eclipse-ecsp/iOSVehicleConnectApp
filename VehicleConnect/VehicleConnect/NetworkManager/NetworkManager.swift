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

// Netowrk status conected or disconnected
import SwiftUI
import Network

// An enum to handle the network status
public enum NetworkStatus: String {
    case connected
    case disconnected
}

// An enum to check the network type
public enum NetworkType: String {
    case wifi
    case cellular
    case wiredEthernet
    case other
}

@available(iOS 13.0, *)
public class NetworkManager: ObservableObject {

    @Published public var isMonitoring = false
    @Published public var status: NetworkStatus = .disconnected
    @Published private var pathStatus = NWPath.Status.requiresConnection
    @Published public var isConnected = true

    var monitor: NWPathMonitor?
   public static let shared = NetworkManager()

    private init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    /// This method is used to start internet network monitoring
    public func startMonitoring() {
        guard !isMonitoring else { return }

        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkStatus_Monitor")
        monitor?.start(queue: queue)
        monitor?.pathUpdateHandler = { path in
        // Monitor runs on a background thread so we need to publish it on the main thread.
            DispatchQueue.main.async {
                if self.pathStatus != path.status {
                    self.pathStatus = path.status
                    self.status = self.pathStatus == .satisfied ? .connected : .disconnected
                    self.isConnected = self.status == .connected ? true : false
                }
            }
        }
        isMonitoring = true
    }

    /// This method is used to stop internet network monitoring
    public func stopMonitoring() {
        guard isMonitoring, let monitor = monitor else { return }
        monitor.cancel()
        self.monitor = nil
        isMonitoring = false
    }
}
