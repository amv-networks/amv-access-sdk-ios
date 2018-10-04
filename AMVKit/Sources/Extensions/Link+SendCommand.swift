import Foundation
import HMKit


extension Link {

    func sendCommand(_ command: [UInt8]) throws {
        try sendCommand(command, sent: {
            guard let error = $0 else {
                return
            }

            BluetoothManager.shared.dispatchConnectionError(error)
        })
    }
}
