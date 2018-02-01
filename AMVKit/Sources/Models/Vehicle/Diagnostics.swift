import AutoAPI
import Foundation


public struct Diagnostics: VehicleUpdateInitable {

    /// Kilometers driven by the vehicle
    public let mileage: UInt32


    // MARK: VehicleUpdateInitable

    typealias Command = AutoAPI.DiagnosticsCommand
    typealias Values = UInt32


    static var extractedResponseValues: (AutoAPI.DiagnosticsCommand.Response) -> UInt32 {
        return { $0.mileage }
    }

    static var extractedVSValues: (AutoAPI.DiagnosticsCommand.VehicleStatus) -> UInt32 {
        return { $0.mileage }
    }


    init(values: UInt32) {
        mileage = values
    }
}
