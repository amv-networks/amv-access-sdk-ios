import Foundation
import AutoAPI

struct HmCommandFactory : CommandFactory {
    static func createCommand(_ commandType: CommandType) -> Command {
        switch commandType {
        case .lockDoors:
            return SimpleCommand(bytes: AutoAPI.DoorLocksCommand.lockDoorsBytes(.lock))
            
        case .unlockDoors:
            return SimpleCommand(bytes : AutoAPI.DoorLocksCommand.lockDoorsBytes(.unlock))
        }
    }
}
