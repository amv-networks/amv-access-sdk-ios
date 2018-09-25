import AutoAPI
import Foundation


public struct AMVCharging {

    /// If the charging plug is connected or not
    public let isPlugConnected: Bool
}

extension AMVCharging: VehicleUpdateInitable {

    typealias IncomingCommand = Charging


    init?(incomingCommand: Charging) {
        guard let chargingState = incomingCommand.chargingState else {
            return nil
        }

        isPlugConnected = chargingState != .disconnected
    }
}
