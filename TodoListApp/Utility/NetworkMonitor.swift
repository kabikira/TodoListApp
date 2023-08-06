//
//  NetworkMonitor.swift
//  TodoListApp
//
//  Created by koala panda on 2023/07/30.
//

import Foundation
import Network


final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor: NWPathMonitor
    static let connectionLost = Notification.Name("Not connected to the network.")

    private init() {
        self.monitor = NWPathMonitor()
    }
    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
            } else {
                NotificationCenter.default.post(name: NetworkMonitor.connectionLost, object: nil)
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
