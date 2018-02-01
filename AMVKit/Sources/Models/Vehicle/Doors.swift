import AutoAPI
import Foundation


public struct Doors: VehicleUpdateInitable {

    /// If All the doors are locked
    public let isLocked: Bool

    /// If Any of the doors is open
    public let isOpen: Bool


    // MARK: VehicleUpdateInitable

    typealias Command = AutoAPI.DoorLocksCommand
    typealias Values = [Command.Door]


    static var extractedResponseValues: (AutoAPI.DoorLocksCommand.Response) -> [Command.Door] {
        return { $0.doors }
    }

    static var extractedVSValues: (AutoAPI.DoorLocksCommand.VehicleStatus) -> [Command.Door] {
        return { $0.doors }
    }


    init(values: [AutoAPI.DoorLocksCommand.Door]) {
        isLocked = !values.contains { $0.lockStatus == .unlocked }
        isOpen = values.contains { $0.positionStatus == .open }
    }
}
