import AutoAPI
import Foundation


public struct Charging: VehicleUpdateInitable {
    
    /// If the charging plug is connected or not
    public let isPlugConnected: Bool
    
    
    // MARK: VehicleUpdateInitable
    
    typealias Command = AutoAPI.ChargingCommand
    typealias Values = Command.ChargingState
    
    
    static var extractedResponseValues: (AutoAPI.ChargingCommand.Response) -> Command.ChargingState {
        return { $0.chargingState }
    }
    
    static var extractedVSValues: (AutoAPI.ChargingCommand.VehicleStatus) -> Command.ChargingState {
        return { $0.chargingState }
    }
    
    
    init(values: Command.ChargingState) {
        isPlugConnected = values != .disconnected
    }
}
