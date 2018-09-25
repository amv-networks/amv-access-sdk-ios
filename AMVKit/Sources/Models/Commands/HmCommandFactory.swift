import Foundation
import AutoAPI

struct HmCommandFactory : CommandFactory {
    static func createCommand(_ commandType: CommandType) -> AMVCommand {
        switch commandType {
        case .lockDoors:
            return SimpleCommand(bytes: DoorLocks.lockUnlock(.lock))
            
        case .unlockDoors:
            return SimpleCommand(bytes : DoorLocks.lockUnlock(.unlock))
            
        case .requestVehicleState:
            return SimpleCommand(bytes: VehicleStatus.getVehicleStatus)
        }
    }
}
