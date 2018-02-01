import Foundation


public typealias Base64 = String
public typealias Hex = String


/// Custom error.
///
/// - disconnected: connection to a device / vehicle is not connected
/// - invalidData: data is corrupt or invalid for usage (i.e. for creating a certificate)
/// - invalidResponse: response isn't an httpURLResponse or of the expected status code
/// - invalidURL: URL could not be created from hardcoded values (programmer error)
/// - nonceGeneration: device failed to create secure pseudo-random bytes
/// - uninitialised: AMVKit is not initialised, or method is missing expected values
public enum Failure: Error {
    case disconnected
    case invalidData
    case invalidResponse
    case invalidURL
    case nonceGeneration
    case uninitialised
}

/// Async return value.
///
/// Used when returning a response / result from a server,
/// bluetooth connection or another async task.
///
/// - error: could be an OS Error, Failure, HMKit Error or a ServerError
/// - success: generic value (usually defined in a method's signature)
public enum Result<T> {
    case error(Error)
    case success(T)
}
