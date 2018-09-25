import AutoAPI
import Foundation


/// An update received from the vehicle.
///
/// This could be *charging*, *diagnostics*, *doors* or *keys* update.
public protocol VehicleUpdate {

}


protocol VehicleUpdateInitable: VehicleUpdate  {

    associatedtype IncomingCommand: Command


    init?(incomingCommand: IncomingCommand)
    init?(vehicleState: VehicleState)
}

extension VehicleUpdateInitable {

    init?(vehicleState: VehicleState) {
        guard let command = vehicleState as? IncomingCommand else {
            return nil
        }

        self.init(incomingCommand: command)
    }
}
