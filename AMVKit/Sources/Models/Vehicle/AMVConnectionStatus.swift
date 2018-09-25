import Foundation


/// The status of the connection with the vehicle.
///
/// - disconnected: The vehicle disconnected
/// - connected: The link to the vehicle was established
/// - authenticated: The vehicle is authenticated
public enum AMVConnectionStatus: VehicleUpdate {
    case disconnected
    case connected
    case authenticated
}
