import AutoAPI
import Foundation
import HMKit


struct BluetoothManager {

    static let shared = BluetoothManager()


    // MARK: Methods

    func dispatchConnectionError(_ error: Error) {
        // The order matters
        AMVKit.shared.vehicleUpdateHandler?(.error(error))
        AMVKit.shared.disconnect()
    }

    func dispatchConnectionSuccess(_ success: VehicleUpdate) {
        AMVKit.shared.vehicleUpdateHandler?(.success(success))
    }
}

extension BluetoothManager: HMLinkDelegate {

    func link(_ link: HMLink, stateChanged previousState: HMLinkState) {
        switch link.state {
        case .authenticated:    dispatchConnectionSuccess(AMVConnectionStatus.authenticated)
        case .connected:        dispatchConnectionSuccess(AMVConnectionStatus.connected)
        case .disconnected:     dispatchConnectionSuccess(AMVConnectionStatus.disconnected)
        }
    }

    func link(_ link: HMLink, commandReceived bytes: [UInt8]) {
        guard let command = AutoAPI.parseBinary(bytes) else {
            return
        }

        // Extract a 'single' command or 'multiple' from VS
        if let state = command as? VehicleState {
            guard let vehicleUpdate = extractVehicleUpdate(state) else {
                return
            }

            dispatchConnectionSuccess(vehicleUpdate)
        }
        else if let vehicleStatus = command as? VehicleStatus {
            vehicleStatus.states?.compactMap {
                self.extractVehicleUpdate($0)
            }.forEach {
                self.dispatchConnectionSuccess($0)
            }
        }
    }

    func link(_ link: HMLink, authorisationRequestedBy serialNumber: [UInt8], approve: @escaping Approve, timeout: TimeInterval) {
        // Just in case
        do {
            try approve()
        }
        catch {
            dispatchConnectionError(error)
        }
    }

    func link(_ link: HMLink, revokeCompleted bytes: [UInt8]) {
        // If you want to do something with the Revoke
    }
}

extension BluetoothManager: HMLocalDeviceDelegate {

    func localDevice(stateChanged state: HMLocalDeviceState, oldState: HMLocalDeviceState) {
        // Not interested atm
    }

    func localDevice(didReceiveLink link: HMLink) {
        link.delegate = self
        dispatchConnectionSuccess(AMVConnectionStatus.connected)
    }

    func localDevice(didLoseLink link: HMLink) {
        link.delegate = nil
    }
}

private extension BluetoothManager {

    func extractVehicleUpdate(_ state: VehicleState) -> VehicleUpdate? {
        if let charging = AMVCharging(vehicleState: state) {
            return charging
        }
        else if let diagnostics = AMVDiagnostics(vehicleState: state) {
            return diagnostics
        }
        else if let doors = AMVDoors(vehicleState: state) {
            return doors
        }
        else if let keys = AMVKeys(vehicleState: state) {
            return keys
        }
        else {
            return nil
        }
    }
}
