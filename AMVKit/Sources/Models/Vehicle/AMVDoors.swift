import AutoAPI
import Foundation


public struct AMVDoors {

    /// If all the doors are locked
    public let isLocked: Bool
    
    /// If all the doors are unlocked
    public var isUnlocked: Bool {
        return !isLocked
    }

    /// If any of the doors is open
    public let isOpen: Bool
    
    /// If all doors are closed
    public var isClosed: Bool {
        return !isOpen
    }
}

extension AMVDoors: VehicleUpdateInitable {

    typealias IncomingCommand = DoorLocks


    init?(incomingCommand: DoorLocks) {
        guard let doors = incomingCommand.doors else {
            return nil
        }

        isLocked = doors.allSatisfy { $0.lock == .locked }
        isOpen = doors.contains { $0.position == .open }
    }
}
