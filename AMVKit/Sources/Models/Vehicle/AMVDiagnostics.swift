import AutoAPI
import Foundation


public struct AMVDiagnostics {

    /// Kilometers driven by the vehicle
    public let mileage: UInt32
}

extension AMVDiagnostics: VehicleUpdateInitable {

    typealias IncomingCommand = Diagnostics


    init?(incomingCommand: Diagnostics) {
        guard let mileage = incomingCommand.mileage else {
            return nil
        }

        self.mileage = mileage
    }
}
