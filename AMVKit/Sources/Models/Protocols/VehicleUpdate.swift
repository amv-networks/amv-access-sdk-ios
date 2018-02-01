import AutoAPI
import Foundation


/// An update received from the vehicle.
///
/// This could be *charging*, *diagnostics*, *doors* or *keys* update.
public protocol VehicleUpdate {

}


protocol VehicleUpdateInitable: VehicleUpdate {

    associatedtype Command: ResponsePublicValueProtocol, VehicleStatusPublicValueProtocol
    associatedtype Values

    static var extractedResponseValues: (Command.Response) -> Values { get }
    static var extractedVSValues: (Command.VehicleStatus) -> Values { get }

    init?(response: Response)
    init(values: Values)
}

extension VehicleUpdateInitable {

    init?(response: Response) {
        switch response.value {
        case let response as Command.Response:
            self.init(values: Self.extractedResponseValues(response))

        case let vsResponse as AutoAPI.VehicleStatusCommand.Response:
            guard let vs = vsResponse.vehicleStatuses.flatMap({ $0.value as? Command.VehicleStatus }).first else {
                return nil
            }

            self.init(values: Self.extractedVSValues(vs))

        default:
            return nil
        }
    }
}
