import AutoAPI
import Foundation


public struct AMVKeys {

    /// If the keys are inside the vehicle
    public let isInside: Bool
}

extension AMVKeys: VehicleUpdateInitable {

    typealias IncomingCommand = KeyfobPosition


    init?(incomingCommand: KeyfobPosition) {
        guard let position = incomingCommand.relativePosition else {
            return nil
        }

        isInside = position == .inside
    }
}
