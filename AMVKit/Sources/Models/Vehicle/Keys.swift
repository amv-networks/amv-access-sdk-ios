import AutoAPI
import Foundation


public struct Keys: VehicleUpdateInitable {

    /// If the keys are inside the vehicle
    public let isInside: Bool


    // MARK: VehicleUpdateInitable

    typealias Command = AutoAPI.KeyfobPositionCommand
    typealias Values = Command.Position


    static var extractedResponseValues: (AutoAPI.KeyfobPositionCommand.Response) -> Command.Position {
        return { $0 }
    }

    static var extractedVSValues: (AutoAPI.KeyfobPositionCommand.VehicleStatus) -> Command.Position {
        return { $0 }
    }


    init(values: Command.Position) {
        isInside = values == .inside
    }
}
