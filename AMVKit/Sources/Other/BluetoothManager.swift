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

extension BluetoothManager: LinkDelegate {

    func link(_ link: Link, stateChanged previousState: LinkState) {
        switch link.state {
        case .authenticated:    dispatchConnectionSuccess(ConnectionStatus.authenticated)
        case .connected:        dispatchConnectionSuccess(ConnectionStatus.connected)
        case .disconnected:     dispatchConnectionSuccess(ConnectionStatus.disconnected)
        }

        if (link.state == .authenticated) && (previousState != .authenticated) {
            // Giving it a tiny breathing room
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                do {
                    try link.sendCommand(AutoAPI.VehicleStatusCommand.getStateBytes)
                }
                catch {
                    self.dispatchConnectionError(error)
                }
            }
        }
    }

    func link(_ link: Link, commandReceived bytes: [UInt8]) {
        guard let response = AutoAPI.parseIncomingCommand(bytes) else {
            return
        }

        // Just super-simple if-list... (not if-else, cause VS can contain many entries)
        if let charging = Charging(response: response) {
            dispatchConnectionSuccess(charging)
        }

        if let diagnostics = Diagnostics(response: response) {
            dispatchConnectionSuccess(diagnostics)
        }

        if let doors = Doors(response: response) {
            dispatchConnectionSuccess(doors)
        }

        if let keys = Keys(response: response) {
            dispatchConnectionSuccess(keys)
        }
    }

    func link(_ link: Link, authorisationRequestedBy serialNumber: [UInt8], approve: @escaping Approve, timeout: TimeInterval)
    {
        // Just in case
        do {
            try approve()
        }
        catch {
            dispatchConnectionError(error)
        }
    }
}

extension BluetoothManager: LocalDeviceDelegate {

    func localDevice(stateChanged state: LocalDeviceState, oldState: LocalDeviceState) {
        // Not interested atm
    }

    func localDevice(didReceiveLink link: Link) {
        link.delegate = self
    }

    func localDevice(didLoseLink link: Link) {
        link.delegate = nil
    }
}
